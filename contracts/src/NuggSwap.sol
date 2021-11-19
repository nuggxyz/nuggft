// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';
import './interfaces/INuggSwap.sol';
import './interfaces/IERC721Nuggable.sol';
import './libraries/CheapMath.sol';
import './libraries/ShiftLib.sol';

import './interfaces/INuggSwapable.sol';
import './interfaces/IxNUGG.sol';

import './erc721/IERC721.sol';
import './core/Epochable.sol';
import './erc2981/IERC2981.sol';

import './common/Testable.sol';
import './erc721/ERC721Holder.sol';
import './erc1155/ERC1155Holder.sol';

contract NuggSwap is INuggSwap, ERC721Holder, ERC1155Holder, Testable, Epochable {
    using Address for address payable;
    using SwapLib for SwapLib.SwapData;
    using CheapMath for uint256;
    using ShiftLib for uint256;

    mapping(address => mapping(uint256 => address[])) internal _swapOwners;

    mapping(address => uint256) internal _royalty;

    // mapping(uint256 => uint256[]) _encodedSwapData;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal _encodedSwapData;

    mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => uint256)))) internal _encodedOfferData;

    IxNUGG public immutable override xnugg;

    constructor(IxNUGG _xnugg) Epochable(25, uint128(block.number)) {
        xnugg = _xnugg;
    }

    function getSwap(address token, uint256 tokenid)
        external
        view
        override
        returns (
            uint256 swapnum,
            address leader,
            uint128 leaderAmount,
            uint16 amount,
            uint16 precision,
            uint48 epoch,
            bool tokenClaimed,
            bool exists,
            bool is1155
        )
    {
        swapnum = _swapOwners[token][tokenid].length;
        (leader, epoch, amount, precision, tokenClaimed, exists, is1155) = ShiftLib.decodeSwapData(
            _encodedSwapData[token][tokenid][swapnum]
        );
        (leaderAmount, ) = ShiftLib.decodeOfferData(_encodedOfferData[token][tokenid][swapnum][leader]);
    }

    function getSwap(
        address token,
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
            uint16 amount,
            uint16 precision,
            uint48 epoch,
            bool tokenClaimed,
            bool exists,
            bool is1155
        )
    {
        require(_swapnum <= _swapOwners[token][tokenid].length, 'NS:GS:0');
        swapnum = _swapnum;
        (leader, epoch, amount, precision, tokenClaimed, exists, is1155) = ShiftLib.decodeSwapData(
            _encodedSwapData[token][tokenid][swapnum]
        );
        (leaderAmount, ) = ShiftLib.decodeOfferData(_encodedOfferData[token][tokenid][swapnum][leader]);
    }

    function setRoyalty(
        address token,
        address receiver,
        uint16 bps
    ) external payable {
        require(SwapLib.checkOwner(token, msg.sender), 'NS:SRB:0');
        require(msg.value > 10**15, 'NS:SRB:1');

        payable(receiver).sendValue(msg.value);

        _royalty[token] = ShiftLib.encodeRoyaltyData(receiver, bps);
    }

    function submitSwap(
        address token,
        uint256 tokenid,
        uint48 requestedEpoch,
        uint128 requestedFloor
    ) external override {
        _submitSwap(token, tokenid, msg_sender(), requestedEpoch, requestedFloor);
    }

    function submitOffer(address token, uint256 tokenid) external payable override {
        _submitOffer(token, tokenid, msg_sender(), msg_sender(), uint128(msg_value()));
    }

    function submitOfferTo(
        address token,
        uint256 tokenid,
        address to
    ) external payable override {
        _submitOffer(token, tokenid, msg_sender(), to, uint128(msg_value()));
    }

    function submitClaim(address token, uint256 tokenid) external override {
        _submitClaim(token, tokenid, msg_sender(), msg_sender());
    }

    function submitClaimTo(
        address token,
        uint256 tokenid,
        address to
    ) external override {
        _submitClaim(token, tokenid, msg_sender(), to);
    }

    function _submitSwap(
        address token,
        uint256 tokenid,
        address account,
        uint48 requestedEpoch,
        uint128 requestedFloor
    ) internal {
        SwapLib.moveERC721(token, tokenid, account, address(this));

        address[] storage prevSwapOwners = _swapOwners[token][tokenid];

        prevSwapOwners.push(account);

        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(token, tokenid, account);

        handleSubmitSwap(swap, offer, requestedEpoch, requestedFloor);

        saveData(swap, offer);

        emit SubmitSwap(swap.token, swap.tokenid, swap.num, offer.account, offer.amount, swap.epoch);
    }

    function _submitOffer(
        address token,
        uint256 tokenid,
        address sender,
        address to,
        uint128 value
    ) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(token, tokenid, to);

        if (!swap.exists) mintToken(swap);

        handleSubmitOffer(swap, offer, value, sender);

        saveData(swap, offer);

        payRoyalties(token, tokenid, offer.amount - swap.leaderAmount);

        emit SubmitOffer(swap.token, swap.tokenid, swap.num, offer.account, offer.amount);
    }

    // todo - we need to make sure that if any of this fails the transaction still goes through (sending value to xnugg should never fail)

    // todo - we need to check if they implement erc2981 - if they do not send royalties to owner - if they have no owner than no royalties

    function _submitClaim(
        address token,
        uint256 tokenid,
        address sender,
        address to
    ) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(token, tokenid, sender);

        handleSubmitClaim(swap, offer, to);

        saveData(swap, offer);

        emit SubmitClaim(swap.token, swap.tokenid, swap.num, offer.account);
    }

    function mintToken(SwapLib.SwapData memory swap) internal {
        IERC721 _token = IERC721(swap.token);

        require(_token.supportsInterface(type(IERC721Nuggable).interfaceId), 'AUC:MT:0');

        uint256 tokenid = IERC721Nuggable(address(swap.token)).nsMint(swap.activeEpoch);

        ensureActiveSeed();

        require(tokenid == swap.tokenid, 'AUC:MT:2');
        require((_token.ownerOf(swap.tokenid) == address(this)), 'AUC:MT:3');

        handleSubmitSwap(
            swap,
            SwapLib.OfferData({account: address(0), amount: 0, claimed: false}),
            swap.activeEpoch,
            0
        );
    }

    /*
     *  this https://eips.ethereum.org/EIPS/eip-721
     */
    function payRoyalties(
        address token,
        uint256 tokenid,
        uint256 amount
    ) internal {
        (bool found, address receiver, uint256 bps) = SwapLib.checkRoyalties(token, tokenid, _royalty[token]);
        uint256 royalties;
        if (found && receiver != address(xnugg)) {
            royalties = (amount * bps) / SwapLib.FULL_ROYALTY_BPS;
            payable(receiver).sendValue(royalties);
        }

        payable(address(xnugg)).sendValue(amount - royalties);
    }

    function loadData(
        address token,
        uint256 tokenid,
        address account
    ) internal view returns (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) {
        swap.token = token;
        swap.tokenid = tokenid;
        swap.num = _swapOwners[token][tokenid].length;
        swap.activeEpoch = currentEpochId();
        swap.owner = swap.num == 0 ? address(0) : _swapOwners[token][tokenid][swap.num - 1];

        (swap.leader, swap.epoch, swap.amount, swap.precision, swap.tokenClaimed, swap.exists, swap.is1155) = ShiftLib
            .decodeSwapData(_encodedSwapData[swap.token][swap.tokenid][swap.num]);

        (swap.leaderAmount, ) = ShiftLib.decodeOfferData(
            _encodedOfferData[swap.token][swap.tokenid][swap.num][swap.leader]
        );

        // swap = SwapLib.SwapData({
        //     token: token,
        //     tokenid: tokenid,
        //     is1155: is1155,
        //     num: swapnum,
        //     leader: leader,
        //     leaderAmount: leaderAmount,
        //     epoch: epoch,
        //     exists: exists,
        //     amount: tokenAmount,
        //     precision: precision,
        //     tokenClaimed: tokenClaimed,
        //     owner: swapnum == 0 ? address(0) : _swapOwners[token][tokenid][swapnum - 1],
        //     activeEpoch: currentEpochId()
        // });

        offer.account = account;

        (offer.amount, offer.claimed) = ShiftLib.decodeOfferData(_encodedOfferData[token][tokenid][swap.num][account]);

        // offer = SwapLib.OfferData({claimed: claimed, amount: amount, account: account});
    }

    function saveData(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {
        _encodedSwapData[swap.token][swap.tokenid][swap.num] = ShiftLib.encodeSwapData(
            swap.leader,
            swap.epoch,
            swap.amount,
            swap.precision,
            swap.tokenClaimed,
            swap.exists,
            swap.is1155
        );
        _encodedOfferData[swap.token][swap.tokenid][swap.num][offer.account] = ShiftLib.encodeOfferData(
            offer.amount,
            offer.claimed
        );
    }

    function handleSubmitOffer(
        SwapLib.SwapData memory swap,
        SwapLib.OfferData memory offer,
        uint256 amount,
        address
    ) internal pure {
        require(swap.owner != offer.account, 'SL:HSO:0');
        require(!offer.claimed, 'SL:HSO:1');

        offer.amount += uint128(amount);

        require(swap.isActive(), 'SL:OBP:3');
        require(swap.validateOfferIncrement(offer), 'SL:OBP:4');

        swap.leader = offer.account;
    }

    // TODO VUNERABLE TO REENTRANCY
    function handleSubmitClaim(
        SwapLib.SwapData memory swap,
        SwapLib.OfferData memory offer,
        address to
    ) internal {
        require(swap.exists, 'SL:HBC:0');

        SwapLib.ClaimerStatus status = swap.checkClaimer(offer);

        offer.claimed = true;

        require(
            status != SwapLib.ClaimerStatus.DID_NOT_OFFER &&
                status != SwapLib.ClaimerStatus.HAS_ALREADY_CLAIMED &&
                status != SwapLib.ClaimerStatus.WISE_GUY,
            'SL:HBC:1'
        );

        if (
            status == SwapLib.ClaimerStatus.WINNER ||
            status == SwapLib.ClaimerStatus.OWNER_NO_OFFERS ||
            status == SwapLib.ClaimerStatus.OWNER_PAPERHAND
        ) {
            SwapLib.moveERC721(swap.token, swap.tokenid, address(this), to);
            swap.tokenClaimed = true;
            return;
        }

        payable(to).sendValue(offer.amount);
    }

    function handleSubmitSwap(
        SwapLib.SwapData memory swap,
        SwapLib.OfferData memory offer,
        uint48 epoch,
        uint128 floor
    ) internal pure {
        require(!swap.exists, 'AUC:IA:0');

        swap.epoch = epoch;
        require(swap.hasVaildEpoch(), 'AUC:IA:1');

        swap.leader = offer.account;
        swap.exists = true;

        offer.amount = floor;
    }
}
