// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';
import './interfaces/INuggSwap.sol';

import './interfaces/INuggSwapable.sol';
import './interfaces/IxNUGG.sol';

import 'hardhat/console.sol';
import './erc721/IERC721.sol';
import './core/Epochable.sol';

import './common/Testable.sol';
import './erc721/ERC721Holder.sol';

contract NuggSwap is INuggSwap, ERC721Holder, Testable, Epochable {
    using Address for address payable;
    using SwapLib for SwapLib.SwapData;

    mapping(address => mapping(uint256 => address[])) internal _swapOwners;

    // mapping(address => uint256) internal _registrations; // address - supports minting, supports swapping, implements mintable, implements swappable, where to send royalties, approvals

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal _encodedSwapData;

    mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => uint256)))) internal _encodedOfferData;

    IxNUGG public immutable override xnugg;

    constructor(IxNUGG _xnugg) Epochable(25, uint128(block.number)) {
        xnugg = _xnugg;
    }

    function getSwap(address nft, uint256 tokenid)
        external
        view
        override
        returns (
            uint256 swapnum,
            address leader,
            uint128 leaderAmount,
            uint64 epoch,
            bool claimedByOwner,
            bool exists
        )
    {
        swapnum = _swapOwners[nft][tokenid].length;
        (leader, epoch, claimedByOwner, exists) = SwapLib.decodeSwapData(_encodedSwapData[nft][tokenid][swapnum]);
        (leaderAmount, ) = SwapLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][leader]);
    }

    function getSwap(
        address nft,
        uint256 tokenid,
        uint256 _swapnum
    )
        external
        view
        override
        returns (
            uint256 swapnum,
            address leader,
            uint128 leaderAmount,
            uint64 epoch,
            bool claimedByOwner,
            bool exists
        )
    {
        require(_swapnum <= _swapOwners[nft][tokenid].length);
        swapnum = _swapnum;
        (leader, epoch, claimedByOwner, exists) = SwapLib.decodeSwapData(_encodedSwapData[nft][tokenid][swapnum]);
        (leaderAmount, ) = SwapLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][leader]);
    }

    // function registerFromCreation() external {
    //     // require contract in creation
    //     // require that nft implements the NuggSwapable interface
    //     // require that it is an nft (implements ERC721)
    // }

    // function registerByOwner(address nft, address royaltyAddress) external {
    //     // require this is owner of nft
    //     // require that it is an nft (implements ERC721)
    // }

    // function registerByTokenOwners(address nft, address royaltyAddress) external {
    //     // require this is owner of nft
    //     // require that it is an nft (implements ERC721)
    // }

    function submitSwap(
        address nft,
        uint256 tokenid,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) external override {
        _submitSwap(nft, tokenid, msg_sender(), requestedEpoch, requestedFloor);
    }

    function submitOffer(address nft, uint256 tokenid) external payable override {
        _submitOffer(nft, tokenid);
    }

    function submitClaim(address nft, uint256 tokenid) external override {
        _submitClaim(nft, tokenid);
    }

    function _submitSwap(
        address nft,
        uint256 tokenid,
        address account,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) internal {
        SwapLib.takeToken(IERC721(nft), tokenid, account);

        address[] storage prevSwapOwners = _swapOwners[nft][tokenid];

        prevSwapOwners.push(account);

        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, account);

        swap.handleSubmitSwap(offer, requestedEpoch, requestedFloor);

        saveData(swap, offer);

        // prevSwapOwners.push(account);

        emit SubmitSwap(swap.nft, swap.tokenid, swap.num, offer.account, offer.amount, swap.epoch);
    }

    function _submitOffer(address nft, uint256 tokenid) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, msg_sender());

        if (!swap.exists) mintToken(swap);

        swap.handleSubmitOffer(offer, msg_value());

        saveData(swap, offer);

        uint256 increase = offer.amount - swap.leaderAmount;

        // todo - we need to make sure that if any of this fails the transaction still goes through (sending value to xnugg should never fail)
        (address royAccount, uint256 roy) = IERC2981(swap.nft).royaltyInfo(swap.tokenid, increase);

        // todo - we need to check if they implement erc2981 - if they do not send royalties to owner - if they have no owner than no royalties

        if (royAccount == address(xnugg)) {
            payable(address(xnugg)).sendValue(increase);
        } else {
            payable(royAccount).sendValue(roy);
            payable(address(xnugg)).sendValue(increase - roy);
        }

        emit SubmitOffer(swap.nft, swap.tokenid, swap.num, offer.account, offer.amount);
    }

    function _submitClaim(address nft, uint256 tokenid) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, msg_sender());

        swap.handleSubmitClaim(offer);

        saveData(swap, offer);

        emit SubmitClaim(swap.nft, swap.tokenid, swap.num, offer.account);
    }

    function mintToken(SwapLib.SwapData memory swap) internal {
        IERC721 _nft = IERC721(swap.nft);

        require(_nft.supportsInterface(type(INuggMintable).interfaceId), 'AUC:MT:0');

        uint256 tokenid = INuggMintable(address(swap.nft)).nuggSwapMint(swap.activeEpoch);

        ensureActiveSeed();

        require(tokenid == swap.tokenid, 'AUC:MT:2');
        require((_nft.ownerOf(swap.tokenid) == address(this)), 'AUC:MT:3');

        swap.handleSubmitSwap(SwapLib.OfferData({account: address(0), amount: 0, claimed: false}), swap.activeEpoch, 0);
    }

    function loadData(
        address nft,
        uint256 tokenid,
        address account
    ) internal view returns (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) {
        uint256 swapnum = _swapOwners[nft][tokenid].length;

        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeSwapData(
            _encodedSwapData[nft][tokenid][swapnum]
        );

        (uint128 leaderAmount, ) = SwapLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][leader]);
        console.log('yellow', swapnum);
        swap = SwapLib.SwapData({
            nft: nft,
            tokenid: tokenid,
            num: swapnum,
            leader: leader,
            leaderAmount: leaderAmount,
            epoch: epoch,
            exists: exists,
            claimedByOwner: claimedByOwner,
            owner: swapnum == 0 ? address(0) : _swapOwners[nft][tokenid][swapnum - 1],
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
