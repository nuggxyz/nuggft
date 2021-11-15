// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';

import './interfaces/INuggSwapable.sol';
import './interfaces/INuggETH.sol';

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

    event OfferPlaced(address nft, uint256 tokenId, uint256 swapNum, address account, uint256 amount);

    event SwapInit(uint256 indexed epoch);

    event Claim(address nft, uint256 tokenId, uint256 swapNum, address indexed account);

    INuggETH immutable nuggeth;

    constructor(INuggETH _nuggeth) Epochable(250, uint128(block.number)) {
        nuggeth = _nuggeth;
    }

    function startSwap(
        address nft,
        uint256 tokenId,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) external {
        _startSwap(nft, tokenId, msg_sender(), requestedEpoch, requestedFloor);
    }

    function placeOffer(
        address nft,
        uint256 tokenId,
        uint256 swapNum
    ) external payable {
        _placeOffer(nft, tokenId, swapNum);
    }

    function claim(
        address nft,
        uint256 tokenId,
        uint256 swapNum
    ) external {
        _claim(nft, tokenId, swapNum);
    }

    function _startSwap(
        address nft,
        uint256 tokenId,
        address account,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) internal {
        SwapLib.takeToken(IERC721(nft), tokenId, account);

        address[] storage prevSwapOwners = _swapOwners[nft][tokenId];

        uint256 swapNum = uint32(prevSwapOwners.length);

        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenId, swapNum, account);

        swap.handleInitSwap(offer, requestedEpoch, requestedFloor);

        prevSwapOwners.push(account);

        saveData(swap, offer);
    }

    function _placeOffer(
        address nft,
        uint256 tokenId,
        uint256 swapNum
    ) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenId, swapNum, msg_sender());

        if (!swap.exists) {
            SwapLib.mintToken(swap);
            _swapOwners[nft][tokenId].push(address(0));
        }

        swap.handleOfferPlaced(offer, msg_value());

        saveData(swap, offer);

        uint256 increase = offer.amount - swap.leaderAmount;

        (address royAccount, uint256 roy) = IERC2981(swap.nft).royaltyInfo(swap.tokenId, increase);

        if (royAccount == address(nuggeth)) {
            nuggeth.onERC2981Received{value: increase}(
                address(this),
                offer.account,
                swap.nft,
                tokenId,
                address(0),
                0,
                ''
            );
        } else {
            IERC2981Receiver(royAccount).onERC2981Received{value: roy}(
                address(this),
                offer.account,
                swap.nft,
                swap.tokenId,
                address(0),
                0,
                ''
            );
            nuggeth.onERC2981Received{value: increase - roy}(
                address(this),
                offer.account,
                swap.nft,
                tokenId,
                address(0),
                0,
                ''
            );
        }

        emit OfferPlaced(swap.nft, swap.tokenId, swap.num, offer.account, offer.amount);
    }

    function _claim(
        address nft,
        uint256 tokenId,
        uint256 swapNum
    ) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenId, swapNum, msg_sender());

        swap.handleOfferClaim(offer);

        saveData(swap, offer);

        emit Claim(swap.nft, swap.tokenId, swap.num, offer.account);
    }

    function loadData(
        address nft,
        uint256 tokenId,
        uint256 swapNum,
        address account
    ) internal view returns (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) {
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeSwapData(
            _encodedSwapData[nft][tokenId][swapNum]
        );

        (uint128 leaderAmount, ) = SwapLib.decodeOfferData(_encodedOfferData[nft][tokenId][swapNum][leader]);

        swap = SwapLib.SwapData({
            nft: nft,
            tokenId: tokenId,
            num: swapNum,
            leader: leader,
            leaderAmount: leaderAmount,
            epoch: epoch,
            exists: exists,
            claimedByOwner: claimedByOwner,
            owner: _swapOwners[nft][tokenId].length > swapNum ? _swapOwners[nft][tokenId][swapNum] : address(0),
            activeEpoch: currentEpochId()
        });

        (uint128 amount, bool claimed) = SwapLib.decodeOfferData(_encodedOfferData[nft][tokenId][swapNum][account]);

        offer = SwapLib.OfferData({claimed: claimed, amount: amount, account: account});
    }

    function saveData(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {
        _encodedSwapData[swap.nft][swap.tokenId][swap.num] = SwapLib.encodeSwapData(
            swap.leader,
            swap.epoch,
            swap.claimedByOwner,
            swap.exists
        );
        _encodedOfferData[swap.nft][swap.tokenId][swap.num][offer.account] = SwapLib.encodeOfferData(
            offer.amount,
            offer.claimed
        );
    }
}
