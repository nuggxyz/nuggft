// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';
import './interfaces/INuggSwap.sol';
import './libraries/EpochLib.sol';
import './libraries/RoyaltyLib.sol';
import './modules/SwapModule.sol';

import './libraries/ShiftLib.sol';
import './interfaces/IxNUGG.sol';
// import 'hardhat/console.sol';
import './ercs/erc721/IERC721.sol';
import './ercs/erc2981/IERC2981.sol';
import './ercs/erc721/ERC721Holder.sol';
import './ercs/erc1155/ERC1155Holder.sol';

contract NuggSwap is INuggSwap, ERC721Holder, ERC1155Holder {
    using Address for address;
    using EpochLib for uint256;
    using ShiftLib for uint256;
    using SwapModule for uint256;

    IxNUGG public immutable override xnugg;

    uint256 public fees;

    mapping(address => uint256) royalties;

    address public owner;

    event FeesClaimed(uint256 amount);
    event OwnerChanged(address oldOwner, address newOwner);
    event RoyaltiesClaimed(address token, address projectOwner, uint256 amount);

    constructor(address _xnugg) {
        xnugg = IxNUGG(_xnugg);
        owner = msg.sender;
    }

    function submitCoreOffer(address token, uint256 tokenid) external payable override {
        uint256 activeEpoch = EpochLib.activeEpoch();

        (, , , uint256 offer, uint256 fee0, uint256 fee1) = SwapModule.submitCoreOffer(
            token,
            tokenid,
            activeEpoch,
            msg.sender,
            msg.value
        );

        RoyaltyModule.execute0(staker, token, fee0);
        RoyaltyModule.execure1(staker, token, fee1);

        emit SubmitOffer(token, tokenid, msg.sender, msg.value);
    }

    function submitBasicOffer(address token, uint256 tokenid) external payable override {
        (, , , uint256 offer, uint256 fee0, uint256 fee1) = SwapModule.submitBasicOffer(
            token,
            tokenid,
            msg.sender,
            msg.value
        );

        emit SubmitOffer(token, tokenid, msg.sender, msg.value);
    }

    function accept(
        address token,
        uint256 tokenid,
        address offerer
    ) external {
        (, , uint256 offer, ) = acceptBasicOffer(token, tokenid, offerer, msg.sender);

        uint256 owed = RoyaltyMod.execute0(staker, token, offer.eth());

        msg.sender.sendValue(owed);
    }

    function startBasicSwap(
        address token,
        uint256 tokenid,
        uint256 price,
        bool is1155
    ) external override {
        startBasicSwap(token, tokenid, msg.sender, requestedEpoch, price);

        emit SubmitSwap(token, tokenid, msg.sender, price, epoch);
    }

    function startCoreSwap(
        address token,
        uint256 tokenid,
        uint256 price,
        bool is1155
    ) external override {
        startCoreSwap(token, tokenid, msg.sender, requestedEpoch, price);

        emit SubmitSwap(token, tokenid, msg.sender, price, epoch);
    }

    function submitClaim(
        address token,
        uint256 tokenid,
        uint256 index
    ) external override {
        emit SubmitClaim(token, tokenid, index, msg.sender);
    }

    function claimFees() external {
        require(msg.sender == owner, 'NS:CF:0');
        uint256 amount = RoyaltyLib.clearFees();
        msg.sender.sendValue(amount);
        emit FeesClaimed(amount);
    }

    function claimRoyalties(address token, uint256 tokenid) external {
        if (msg.sender != owner) {
            (bool ok, address addr) = RoyaltyLib.checkOwnerOrRoyalty(token, tokenid);
            require(ok && addr == msg.sender, 'NS:CR:0');
        }
        uint256 amount = RoyaltyLib.clearRoyalties(token);
        msg.sender.sendValue(amount);
        emit RoyaltiesClaimed(token, msg.sender, amount);
    }

    function setProjectOwner(address _owner) external {
        require(msg.sender == owner);
        owner = _owner;
        // emit ProjectOwnerChanged(owner, _owner);
    }

    function setOwner(address _owner) external {
        require(msg.sender == owner);
        emit OwnerChanged(owner, _owner);
        owner = _owner;
    }

    function getSwap(
        address token,
        uint256 tokenid,
        uint256 index
    ) external view override returns (SwapData memory res) {
        // var (, , , ) = SwapLib.loadStorage(token, tokenid, index, address(0));
        // res.index = _swapnum > numSwaps ? numSwaps : _swapnum;
        // res.amount = uint128(leaderData);
    }
}
