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

    enum TokenType {
        erc721,
        erc1155,
        erc20
    }

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
        (leader, epoch, claimedByOwner, exists) = ShiftLib.decodeSwapData(_encodedSwapData[nft][tokenid][swapnum]);
        (leaderAmount, ) = ShiftLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][leader]);
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
        require(_swapnum <= _swapOwners[nft][tokenid].length, 'NS:GS:0');
        swapnum = _swapnum;
        (leader, epoch, claimedByOwner, exists) = ShiftLib.decodeSwapData(_encodedSwapData[nft][tokenid][swapnum]);
        (leaderAmount, ) = ShiftLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][leader]);
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
        address nft,
        uint256 tokenid,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) external override {
        _submitSwap(nft, tokenid, msg_sender(), requestedEpoch, requestedFloor);
    }

    function submitOffer(address nft, uint256 tokenid) external payable override {
        _submitOffer(nft, tokenid, msg_sender(), msg_sender(), uint128(msg_value()));
    }

    function submitOfferTo(
        address nft,
        uint256 tokenid,
        address to
    ) external payable override {
        _submitOffer(nft, tokenid, msg_sender(), to, uint128(msg_value()));
    }

    function submitClaim(address nft, uint256 tokenid) external override {
        _submitClaim(nft, tokenid, msg_sender(), msg_sender());
    }

    function submitClaimTo(
        address nft,
        uint256 tokenid,
        address to
    ) external override {
        _submitClaim(nft, tokenid, msg_sender(), to);
    }

    function _submitSwap(
        address nft,
        uint256 tokenid,
        address account,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) internal {
        SwapLib.moveERC721(nft, tokenid, account, address(this));

        address[] storage prevSwapOwners = _swapOwners[nft][tokenid];

        prevSwapOwners.push(account);

        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, account);

        handleSubmitSwap(swap, offer, requestedEpoch, requestedFloor);

        saveData(swap, offer);

        emit SubmitSwap(swap.nft, swap.tokenid, swap.num, offer.account, offer.amount, swap.epoch);
    }

    function _submitOffer(
        address nft,
        uint256 tokenid,
        address sender,
        address to,
        uint128 value
    ) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, to);

        if (!swap.exists) mintToken(swap);

        handleSubmitOffer(swap, offer, value, sender);

        saveData(swap, offer);

        payRoyalties(nft, tokenid, offer.amount - swap.leaderAmount);

        emit SubmitOffer(swap.nft, swap.tokenid, swap.num, offer.account, offer.amount);
    }

    // todo - we need to make sure that if any of this fails the transaction still goes through (sending value to xnugg should never fail)

    // todo - we need to check if they implement erc2981 - if they do not send royalties to owner - if they have no owner than no royalties

    function _submitClaim(
        address nft,
        uint256 tokenid,
        address sender,
        address to
    ) internal {
        (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(nft, tokenid, sender);

        handleSubmitClaim(swap, offer, to);

        saveData(swap, offer);

        emit SubmitClaim(swap.nft, swap.tokenid, swap.num, offer.account);
    }

    function mintToken(SwapLib.SwapData memory swap) internal {
        IERC721 _nft = IERC721(swap.nft);

        require(_nft.supportsInterface(type(IERC721Nuggable).interfaceId), 'AUC:MT:0');

        uint256 tokenid = IERC721Nuggable(address(swap.nft)).nsMint(swap.activeEpoch);

        ensureActiveSeed();

        require(tokenid == swap.tokenid, 'AUC:MT:2');
        require((_nft.ownerOf(swap.tokenid) == address(this)), 'AUC:MT:3');

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
        address nft,
        uint256 tokenid,
        uint256 amount
    ) internal returns (uint256 remainder, uint256 royalties) {
        remainder = amount;

        uint256 bps;
        address receiver;

        if (receiver != address(0) && receiver != address(xnugg)) {
            require(remainder > royalties, 'NS:PR:0');

            remainder -= royalties;
            payable(receiver).sendValue(royalties);
        }

        payable(address(xnugg)).sendValue(remainder);
    }

    function loadData(
        address nft,
        uint256 tokenid,
        address account
    ) internal view returns (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) {
        uint256 swapnum = _swapOwners[nft][tokenid].length;

        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = ShiftLib.decodeSwapData(
            _encodedSwapData[nft][tokenid][swapnum]
        );

        (uint128 leaderAmount, ) = ShiftLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][leader]);

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

        (uint128 amount, bool claimed) = ShiftLib.decodeOfferData(_encodedOfferData[nft][tokenid][swapnum][account]);

        offer = SwapLib.OfferData({claimed: claimed, amount: amount, account: account});
    }

    function saveData(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {
        _encodedSwapData[swap.nft][swap.tokenid][swap.num] = ShiftLib.encodeSwapData(
            swap.leader,
            swap.epoch,
            swap.claimedByOwner,
            swap.exists
        );
        _encodedOfferData[swap.nft][swap.tokenid][swap.num][offer.account] = ShiftLib.encodeOfferData(
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
            SwapLib.moveERC721(swap.nft, swap.tokenid, address(this), to);
            swap.claimedByOwner = true;
            return;
        }

        payable(to).sendValue(offer.amount);
    }

    function handleSubmitSwap(
        SwapLib.SwapData memory swap,
        SwapLib.OfferData memory offer,
        uint64 epoch,
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
