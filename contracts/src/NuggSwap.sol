// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';
import './interfaces/INuggSwap.sol';
// import './interfaces/IERC721Nuggable.sol';
import './libraries/CheapMath.sol';
import './libraries/ShiftLib.sol';

// import './interfaces/INuggSwapable.sol';
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
    using CheapMath for uint16;
    using ShiftLib for uint256;

    struct Storage {
        uint256[] datas;
        mapping(address => uint256) users;
    }

    function loadStorage(
        address token,
        uint256 tokenid,
        address account
    )
        internal
        view
        returns (
            uint256 swapnum,
            uint256 swapData,
            uint256 offerData,
            uint256 leaderData
        )
    {
        // ms_slot = keccak256("com.mycompany.my.storage")

        Storage storage s;

        assembly {
            s.slot := keccak256(token, tokenid)
            swapnum := sload(s.slot)
        }

        if (swapnum == 0) return (0, 0, 0, 0);

        swapData = s.datas[swapnum - 1];

        offerData = s.users[account];
        leaderData = s.users[address(uint160(swapData))];
    }

    // mapping(address => mapping(uint256 => address[])) internal _swapOwners;

    mapping(address => uint256) internal _royalty;

    // uint256 _vault;

    mapping(address => uint256) _royalties;

    // mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal _encodedSwapData;

    // mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => uint256)))) internal _encodedOfferData;

    IxNUGG public immutable override xnugg;

    constructor(address _xnugg) Epochable(25, uint128(block.number)) {
        xnugg = IxNUGG(_xnugg);
    }

    function submitOffer(address token, uint256 tokenid) external payable override {
        _submitOffer(token, tokenid, msg_sender(), msg_sender(), uint128(msg_value()));
    }

    function getSwap(
        address token,
        uint256 tokenid,
        uint256 _swapnum
    ) external view override returns (SwapData memory res) {
        (uint256 numSwaps, uint256 swapData, uint256 offerData, uint256 leaderData) = loadStorage(
            token,
            tokenid,
            address(0)
        );

        res.swapnum = _swapnum > numSwaps ? numSwaps : _swapnum;

        // (res.leader, res.epoch, res.bps, res.is1155, res.tokenClaimed, res.royClaimed)
        res.amount = uint128(leaderData);
        // (res.amount, ) = ShiftLib.decodeOfferData(leaderData);
    }

    // function setRoyalty(
    //     address token,
    //     address receiver,
    //     uint16 bps
    // ) external payable {
    //     require(SwapLib.checkOwner(token, msg.sender) || token == msg.sender, 'NS:SRB:0');
    //     require(msg.value > 10**15, 'NS:SRB:1');

    //     payable(receiver).sendValue(msg.value);

    //     _royalty[token] = ShiftLib.encodeRoyaltyData(receiver, bps);
    // }

    function submitSwap(
        address token,
        uint256 tokenid,
        uint48 requestedEpoch,
        uint128 requestedFloor,
        bool is1155
    ) external override {
        _submitSwap(token, tokenid, msg_sender(), requestedEpoch, requestedFloor, is1155);
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
        uint256 requestedFloor,
        bool is1155 // uint16 tokenAmount, // uint8 tokenPrecision
    ) internal {
        Storage storage s;
        uint256 swapnum;
        assembly {
            s.slot := keccak256(token, tokenid)
            swapnum := sload(s.slot)
        }

        uint256 epoch = currentEpochId() + requestedEpoch;

        uint256 swapData = uint256(uint160(account)).setEpoch(epoch);
        uint256 offerData = requestedFloor.setOwner();

        if (is1155) {
            SwapLib.moveERC1155(token, tokenid, account, address(this));
            swapData.setIs1155();
        } else SwapLib.moveERC721(token, tokenid, account, address(this));

        s.users[account] = offerData;

        s.datas.push(swapData);

        emit SubmitSwap(token, tokenid, swapnum, account, requestedFloor, epoch);
    }

    function _submitOffer(
        address token,
        uint256 tokenid,
        address account,
        address to,
        uint256 value
    ) internal {
        assert(value <= type(uint128).max); // bc it will always be msg.value

        Storage storage s;

        assembly {
            s.slot := keccak256(token, tokenid)
            // swapnum := sload(s.slot)
        }

        (uint256 numSwaps, uint256 swapData, uint256 offerData, uint256 leaderData) = loadStorage(
            token,
            tokenid,
            account
        );

        uint256 activeEpoch = currentEpochId();

        if (swapData == 0) {
            bool is1155 = mintToken(token, tokenid, activeEpoch);
            swapData.setEpoch(activeEpoch);
            if (is1155) swapData.setIs1155();
        }

        require(!offerData.isOwner(), 'SL:HSO:0');
        require(!offerData.isClaimed(), 'SL:HSO:1');

        // offer.eth += uint128(amount);

        value = offerData.eth() + value;

        require(activeEpoch <= swapData.epoch() && !swapData.isTokenClaimed(), 'SL:OBP:3');
        require(leaderData.eth() < value, 'SL:OBP:4');

        // s.users[account] = ShiftLib.encodeOfferData(requestedFloor, false);
        // payable(address(xnugg)).sendValue(value - leaderData.eth());

        // uint48 epoch = currentEpochId() + requestedEpoch;

        // swap.leader = offer.account;

        // do a bunck of validations

        // handleSubmitOffer(swap, offer, value, sender);

        // saveData(swap, offer);
        s.users[account] = offerData.setEth(value);
        if (numSwaps == 0) s.datas.push(swapData.setAccount(account));
        else s.datas[numSwaps - 1] = swapData.setAccount(account);
        // if (swap.bps > 0) amount -= SwapLib.takeBPS(amount, swap.bps);

        // payRoyalties(swap, offer.eth - swap.eth);

        emit SubmitOffer(token, tokenid, numSwaps, account, value);
    }

    // todo - we need to make sure that if any of this fails the transaction still goes through (sending value to xnugg should never fail)

    // todo - we need to check if they implement erc2981 - if they do not send royalties to owner - if they have no owner than no royalties

    function _submitClaim(
        address token,
        uint256 tokenid,
        address account,
        address to
    ) internal {
        Storage storage s;

        assembly {
            s.slot := keccak256(token, tokenid)
            // swapnum := sload(s.slot)
        }

        (uint256 numSwaps, uint256 swapData, uint256 offerData, uint256 leaderData) = loadStorage(
            token,
            tokenid,
            account
        );

        uint256 activeEpoch = currentEpochId();
        // (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) = loadData(token, tokenid, sender);

        // handleSubmitClaim(swap, offer, to);

        // require(swapData != 0, 'SL:HBC:0');

        bool winner = SwapLib.checkClaimer(account, swapData, leaderData, offerData, activeEpoch);

        // require(
        //     status != SwapLib.ClaimerStatus.DID_NOT_OFFER &&
        //         status != SwapLib.ClaimerStatus.HAS_ALREADY_CLAIMED &&
        //         status != SwapLib.ClaimerStatus.WISE_GUY,
        //     'SL:HBC:1'
        // );

        // offer.claimed = true;

        s.users[account] = offerData.setClaimed();

        if (winner) {
            SwapLib.moveERC721(token, tokenid, address(this), to);
            s.datas[numSwaps - 1] = swapData.setTokenClaimed();

            // swap.tokenClaimed = true;
            // return;
        } else {
            payable(to).sendValue(offerData.eth());
        }

        // if (
        //     status == SwapLib.ClaimerStatus.WINNER ||
        //     status == SwapLib.ClaimerStatus.OWNER_NO_OFFERS ||
        //     status == SwapLib.ClaimerStatus.OWNER_PAPERHAND
        // ) {
        //     SwapLib.moveERC721(swap.token, swap.tokenid, address(this), to);
        //     swap.tokenClaimed = true;
        //     return;
        // }

        // saveData(swap, offer);

        emit SubmitClaim(token, tokenid, numSwaps, account);
    }

    function mintToken(
        address token,
        uint256 tokenid,
        uint256 activeEpoch
    ) internal returns (bool) {
        // TODO mint 1155
        try IERC721(token).safeTransferFrom(address(0), address(this), tokenid, abi.encode(activeEpoch)) {
            return false;
        } catch {
            try IERC1155(token).safeTransferFrom(address(0), address(this), tokenid, 1, abi.encode(activeEpoch)) {
                return true;
            } catch {
                require(false, 'NS:MT:0');
            }
        }
        // swap.epoch = swap.activeEpoch;
    }

    /*
     *  this https://eips.ethereum.org/EIPS/eip-721
     */
    // function payRoyalties(SwapLib.SwapData memory swap, uint256 amount) internal {
    //     if (swap.bps > 0) amount -= SwapLib.takeBPS(amount, swap.bps);

    //     payable(address(xnugg)).sendValue(amount);
    // }

    // function getSwapnum(address token, uint256 tokenid) internal view returns (uint256) {
    //     return _swapOwners[token][tokenid].length;
    // }

    // function loadData2(
    //     address token,
    //     uint256 tokenid,
    //     address account
    // )
    //     internal
    //     view
    //     returns (
    //         uint256 swapnum,
    //         uint256 swapData,
    //         uint256 offerData,
    //         uint256 leaderData
    //     )
    // {
    //     swapnum = _swapOwners[token][tokenid].length;
    //     swapData = _encodedSwapData[token][tokenid][swapnum];
    //     offerData = _encodedOfferData[token][tokenid][swapnum][account];
    //     leaderData = _encodedOfferData[token][tokenid][swapnum][address(uint160(swapData))];
    // }

    // function loadData(
    //     address token,
    //     uint256 tokenid,
    //     address account
    // ) internal view returns (SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) {
    //     swap.token = token;
    //     swap.tokenid = tokenid;
    //     offer.account = account;
    //     swap.num = _swapOwners[token][tokenid].length;

    //     uint256 swapData = _encodedSwapData[swap.token][swap.tokenid][swap.num];

    //     // if (swapData == 0) {
    //     //     return (swap, offer);
    //     // }

    //     swap.activeEpoch = currentEpochId();
    //     swap.owner = swap.num == 0 ? address(0) : _swapOwners[token][tokenid][swap.num - 1];

    //     (swap.leader, swap.epoch, swap.bps, swap.is1155, swap.tokenClaimed, swap.royClaimed) = ShiftLib.decodeSwapData(
    //         swapData
    //     );

    //     // if (swap.leader == address(0)) {
    //     //     return (swap, offer);
    //     // }

    //     (swap.eth, ) = ShiftLib.decodeOfferData(_encodedOfferData[swap.token][swap.tokenid][swap.num][swap.leader]);

    //     (offer.eth, offer.claimed) = ShiftLib.decodeOfferData(_encodedOfferData[token][tokenid][swap.num][account]);
    // }

    // function saveData(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {
    //     // ensureActiveSeed();

    //     _encodedSwapData[swap.token][swap.tokenid][swap.num] = ShiftLib.encodeSwapData(
    //         swap.leader,
    //         swap.epoch,
    //         swap.bps,
    //         swap.is1155,
    //         swap.tokenClaimed,
    //         swap.royClaimed
    //     );
    //     _encodedOfferData[swap.token][swap.tokenid][swap.num][offer.account] = ShiftLib.encodeOfferData(
    //         offer.eth,
    //         offer.claimed
    //     );
    // }

    // function handleSubmitOffer(
    //     SwapLib.SwapData memory swap,
    //     SwapLib.OfferData memory offer,
    //     uint256 amount,
    //     address
    // ) internal pure {
    //     require(swap.owner != offer.account, 'SL:HSO:0');
    //     require(!offer.claimed, 'SL:HSO:1');

    //     offer.eth += uint128(amount);

    //     require(swap.isActive(), 'SL:OBP:3');
    //     require(swap.validateOfferIncrement(offer), 'SL:OBP:4');

    //     swap.leader = offer.account;
    // }

    // TODO VUNERABLE TO REENTRANCY
    // function handleSubmitClaim(
    //     SwapLib.SwapData memory swap,
    //     SwapLib.OfferData memory offer,
    //     address to
    // ) internal {
    //     require(swap.leader != address(0), 'SL:HBC:0');

    //     SwapLib.ClaimerStatus status = swap.checkClaimer(offer);

    //     require(
    //         status != SwapLib.ClaimerStatus.DID_NOT_OFFER &&
    //             status != SwapLib.ClaimerStatus.HAS_ALREADY_CLAIMED &&
    //             status != SwapLib.ClaimerStatus.WISE_GUY,
    //         'SL:HBC:1'
    //     );

    //     offer.claimed = true;

    //     if (
    //         status == SwapLib.ClaimerStatus.WINNER ||
    //         status == SwapLib.ClaimerStatus.OWNER_NO_OFFERS ||
    //         status == SwapLib.ClaimerStatus.OWNER_PAPERHAND
    //     ) {
    //         SwapLib.moveERC721(swap.token, swap.tokenid, address(this), to);
    //         swap.tokenClaimed = true;
    //         return;
    //     }

    //     payable(to).sendValue(offer.eth);
    // }

    // function handleSubmitSwap(
    //     address account,
    //     uint48 epoch,
    //     uint128 floor
    // ) internal pure {
    //     // require(swap.leader == address(0), 'AUC:IA:0');

    //     swap.epoch = epoch;
    //     require(swap.hasVaildEpoch(), 'AUC:IA:1');

    //     swap.leader = offer.account;

    //     offer.eth = floor;
    // }

    // function offerValidations(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function offerChanges(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function offerActions(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function offerEvents(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function claimValidations(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function claimChanges(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function claimActions(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function claimEvents(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function swapChanges(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function swapActions(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}

    // function swapEvents(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) internal {}
}
