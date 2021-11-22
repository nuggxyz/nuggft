// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';
import './interfaces/INuggSwap.sol';
import './libraries/EpochLib.sol';
import './libraries/ShiftLib.sol';
import './interfaces/IxNUGG.sol';
// import 'hardhat/console.sol';
import './erc721/IERC721.sol';
import './erc2981/IERC2981.sol';
import './erc721/ERC721Holder.sol';
import './erc1155/ERC1155Holder.sol';

contract NuggSwap is INuggSwap, ERC721Holder, ERC1155Holder {
    using Address for address;
    using EpochLib for uint256;
    using ShiftLib for uint256;
    using SwapLib for uint256;

    IxNUGG public immutable override xnugg;

    uint256 public fees;

    mapping(address => uint256) royalties;

    address public owner;

    constructor(address _xnugg) {
        xnugg = IxNUGG(_xnugg);
        owner = msg.sender;
        SwapLib.clearFees();

        // console.log('dafees', SwapLib.fees());
    }

    function submitOffer(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external payable override {
        _submitOffer(token, tokenid, swapnum, msg.sender, msg.sender, msg.value);
    }

    function submitOfferSimple(address token) external payable override {
        _submitOffer(token, EpochLib.activeEpoch().formattedToken(), 0, msg.sender, msg.sender, msg.value);
    }

    function submitSwap(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        uint48 requestedEpoch,
        uint128 requestedFloor,
        bool is1155
    ) external override {
        _submitSwap(token, tokenid, swapnum, msg.sender, requestedEpoch, requestedFloor, is1155);
    }

    function submitClaim(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external override {
        _submitClaim(token, tokenid, swapnum, msg.sender, msg.sender);
    }

    function submitClaimSimple(address token, uint256 epoch) external override {
        _submitClaim(token, epoch.formattedToken(), 0, msg.sender, msg.sender);
    }

    event FeesClaimed(uint256 amount);

    event RoyaltiesClaimed(address token, address projectOwner, uint256 amount);

    function claimFees() external {
        require(msg.sender == owner, 'NS:CF:0');

        uint256 amount = SwapLib.clearFees();

        msg.sender.sendValue(amount);

        emit FeesClaimed(amount);
    }

    function claimRoyalties(address token, uint256 tokenid) external {
        if (msg.sender != owner) {
            (bool ok, address addr) = SwapLib.checkOwnerOrRoyalty(token, tokenid);
            require(ok && addr == msg.sender, 'NS:CR:0');
        }

        uint256 amount = SwapLib.clearRoyalties(token);

        msg.sender.sendValue(amount);

        emit RoyaltiesClaimed(token, msg.sender, amount);
    }

    function setOwner(address _owner) external {
        require(msg.sender == owner);
        // emit OwnerChanged(owner, _owner);
        owner = _owner;
    }

    function getSwap(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external view override returns (SwapData memory res) {
        // var (, , , ) = SwapLib.loadStorage(token, tokenid, swapnum, address(0));
        // res.swapnum = _swapnum > numSwaps ? numSwaps : _swapnum;
        // res.amount = uint128(leaderData);
    }

    function _submitOffer(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        address account,
        address to,
        uint256 value
    ) internal {
        (SwapLib.Storage storage s, uint256 swapData, uint256 offerData) = SwapLib.loadStorage(
            token,
            tokenid,
            swapnum,
            to
        );

        uint256 activeEpoch = EpochLib.activeEpoch();

        bool rtm;
        uint256 newSwapData;
        uint256 dust;

        if (swapData.hasRtmFlag()) {
            swapData = 0;
            rtm = true;
        }

        if (swapData != 0) {
            require(!offerData.offerIsOwner(), 'SL:HSO:0');
            require(activeEpoch <= swapData.epoch() && !swapData.swapEndedByOwner(), 'SL:OBP:3');

            s.users[swapData.addr()][swapnum] = swapData;

            newSwapData = newSwapData.setEpoch(swapData.epoch());

            if (swapData.is1155()) newSwapData = newSwapData.setIs1155();
        } else if (swapnum == 0) {
            require(activeEpoch == tokenid.formattedTokenEpoch(), 'SL:-1:0');
            require(tokenid.formattedTokenAddress() == address(this), 'SL:0:0');

            bool is1155 = SwapLib.mintToken(token, tokenid);
            if (is1155) newSwapData = newSwapData.setIs1155();

            if (!rtm) EpochLib.setSeed();

            newSwapData = newSwapData.setEpoch(activeEpoch);
        } else {
            require(false, 'NS:SO:0');
        }

        (newSwapData, dust) = newSwapData.setAccount(to).setEth(offerData.eth() + value);

        require(swapData.eth().pointsWith(100) < newSwapData.eth(), 'SL:OBP:4');

        s.datas[swapnum] = newSwapData;

        if (dust > 0) account.sendValue(dust);

        uint256 increase = newSwapData.eth() - swapData.eth();
        uint256 fee = increase.points(1000);
        address(xnugg).sendValue(increase - fee);
        // fees += fee;
        // SwapLi

        emit SubmitOffer(token, tokenid, swapnum, to, value);
    }

    function _submitClaim(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        address account,
        address to
    ) internal {
        (SwapLib.Storage storage s, uint256 swapData, uint256 offerData) = SwapLib.loadStorage(
            token,
            tokenid,
            swapnum,
            account
        );

        uint256 activeEpoch = EpochLib.activeEpoch();

        bool winner;
        if (swapData.hasRtmFlag()) {
            uint256 epoch = tokenid.formattedTokenEpoch();

            require(activeEpoch > epoch, 'SC:SD:1');
            require(address(this) == tokenid.formattedTokenAddress(), 'SC:SD:2');

            winner = swapData.addr() == account;

            require(winner, 'SC:0:0');

            swapData = uint256(0).setAccount(account).setEpoch(epoch);
        } else {
            winner = SwapLib.checkClaimer(account, swapData, offerData, activeEpoch);
        }

        if (winner) {
            SwapLib.moveERC721(token, tokenid, address(this), to);
            s.datas[swapnum] = swapData.setTokenClaimed();
        } else {
            delete s.users[account][swapnum];

            if (offerData.offerIsOwner()) {
                uint256 royalty = offerData.eth().points(1000);
                uint256 fee = (swapData.eth() - offerData.eth()).points(1000);

                SwapLib.addFeeAndRoyalty(token, fee, royalty);

                to.sendValue(offerData.eth() - (royalty));
            } else {
                to.sendValue(offerData.eth());
            }
        }

        emit SubmitClaim(token, tokenid, swapnum, account);
    }

    function _submitSwap(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        address account,
        uint48 requestedEpoch,
        uint256 requestedFloor,
        bool is1155
    ) internal {
        // only minting swaps can be numbered 0
        require(swapnum > 0, 'NS:SS:-1');

        (SwapLib.Storage storage s, uint256 swapData, ) = SwapLib.loadStorage(token, tokenid, swapnum, account);

        // make sure swap does not exist
        require(swapData == 0, 'NS:SS:0');

        // force swaps to be started in sequential order
        if (swapnum != 1) require(s.datas[swapnum - 1] != 0, 'NS:SS:1');

        // calculate epoch
        uint256 epoch = EpochLib.activeEpoch() + requestedEpoch;

        // build starting swap data
        (swapData, ) = swapData.setAccount(account).setEpoch(epoch).setOfferIsOwner().setEth(requestedFloor);

        // move the token
        if (is1155) {
            SwapLib.moveERC1155(token, tokenid, account, address(this));
            swapData = swapData.setIs1155();
        } else {
            SwapLib.moveERC721(token, tokenid, account, address(this));
        }

        // sstore swapdata
        s.datas[swapnum] = swapData;

        emit SubmitSwap(token, tokenid, swapnum, account, requestedFloor, epoch);
    }

    function rightToMint(address token) external {
        (, uint256 epoch, ) = EpochLib.setSeed();
        (SwapLib.Storage storage s, uint256 data, ) = SwapLib.loadStorage(token, epoch.formattedToken(), 0, msg.sender);
        if (data == 0) s.datas[0] = data.setRtmFlag().setAccount(msg.sender);
    }
}
