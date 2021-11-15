// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';

import './interfaces/INuggSwapable.sol';
import './interfaces/IxNUGG.sol';

import 'hardhat/console.sol';
import './erc721/IERC721.sol';
import './core/Epochable.sol';

import './common/Testable.sol';
import './erc721/ERC721Holder.sol';

contract NuggSwap is ERC721Holder, Testable, Epochable {
    using Address for address payable;
    using SwapLib for SwapLib.SwapData;

    mapping(address => mapping(uint256 => address[])) internal _swapOwners;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal _encodedSwapData;

    mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => uint256)))) internal _encodedOfferData;

    event Offer(address nft, uint256 tokenid, uint256 swapnum, address account, uint256 amount);

    event SwapInit(uint256 indexed epoch);

    event Claim(address nft, uint256 tokenid, uint256 swapnum, address indexed account);

    IxNUGG immutable xnugg;

    constructor(IxNUGG _xnugg) Epochable(250, uint128(block.number)) {
        xnugg = _xnugg;
    }

    function startSwap(
        address nft,
        uint256 tokenid,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) external {
        _startSwap(nft, tokenid, msg_sender(), requestedEpoch, requestedFloor);
    }

    function submitOffer(
        address nft,
        uint256 tokenid,
        uint256 swapnum
    ) external payable {
        _offer(nft, tokenid, swapnum);
    }

    function submitClaim(
        address nft,
        uint256 tokenid,
        uint256 swapnum
    ) external {
        _claim(nft, tokenid, swapnum);
    }

    function _startSwap(
        address nft,
        uint256 tokenid,
        address account,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) internal {
        SwapLib.takeToken(IERC721(nft), tokenid, account);

        address[] storage prevSwapOwners = _swapOwners[nft][tokenid];

        uint256 swapnum = uint32(prevSwapOwners.length);

        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, swapnum, account);

        swap.handleInitSwap(offer, requestedEpoch, requestedFloor);

        prevSwapOwners.push(account);

        saveData(swap, offer);
    }

    function _offer(
        address nft,
        uint256 tokenid,
        uint256 swapnum
    ) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, swapnum, msg_sender());

        if (!swap.exists) {
            SwapLib.mintToken(swap);
            _swapOwners[nft][tokenid].push(address(0));
        }

        swap.handleOfferSubmit(offer, msg_value());

        saveData(swap, offer);

        uint256 increase = offer.amount - swap.leaderAmount;

        (address royAccount, uint256 roy) = IERC2981(swap.nft).royaltyInfo(swap.tokenid, increase);

        // todo - we need to check if they implement erc2981 - if they do not send royalties to owner - if they have no owner than no royalties

        if (royAccount == address(xnugg)) {
            xnugg.onERC2981Received{value: increase}(
                address(this),
                offer.account,
                swap.nft,
                tokenid,
                address(0),
                0,
                ''
            );
        } else {
            IERC2981Receiver(royAccount).onERC2981Received{value: roy}(
                address(this),
                offer.account,
                swap.nft,
                swap.tokenid,
                address(0),
                0,
                ''
            );
            xnugg.onERC2981Received{value: increase - roy}(
                address(this),
                offer.account,
                swap.nft,
                tokenid,
                address(0),
                0,
                ''
            );
        }

        emit Offer(swap.nft, swap.tokenid, swap.num, offer.account, offer.amount);
    }

    function _claim(
        address nft,
        uint256 tokenid,
        uint256 swapnum
    ) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, swapnum, msg_sender());

        swap.handleOfferClaim(offer);

        saveData(swap, offer);

        emit Claim(swap.nft, swap.tokenid, swap.num, offer.account);
    }

    function loadData(
        address nft,
        uint256 tokenid,
        uint256 swapnum,
        address account
    ) internal view returns (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) {
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeSwapData(
            _encodedSwapData[nft][tokenid][swapnum]
        );

        (uint128 leaderAmount, ) = SwapLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][leader]);

        swap = SwapLib.SwapData({
            nft: nft,
            tokenid: tokenid,
            num: swapnum,
            leader: leader,
            leaderAmount: leaderAmount,
            epoch: epoch,
            exists: exists,
            claimedByOwner: claimedByOwner,
            owner: _swapOwners[nft][tokenid].length > swapnum ? _swapOwners[nft][tokenid][swapnum] : address(0),
            activeEpoch: currentEpochId()
        });

        (uint128 amount, bool claimed) = SwapLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][account]);

        offer = SwapLib.OfferData({claimed: claimed, amount: amount, account: account});
    }

    function saveData(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {
        _encodedSwapData[swap.nft][swap.tokenid][swap.num] = SwapLib.encodeSwapData(
            swap.leader,
            swap.epoch,
            swap.claimedByOwner,
            swap.exists
        );
        _encodedOfferData[swap.nft][swap.tokenid][swap.num][offer.account] = SwapLib.encodeOfferData(
            offer.amount,
            offer.claimed
        );
    }
}
