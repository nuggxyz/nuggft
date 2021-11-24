// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';
import './interfaces/INuggSwap.sol';
import './libraries/EpochLib.sol';
import './libraries/RoyaltyLib.sol';
import './modules/Swap.mod.sol';

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
    using SwapMod for uint256;

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

    function submitOffer(address token, uint256 tokenid) external payable override {
        uint256 activeEpoch = EpochLib.activeEpoch();

        uint256 increase = SwapLib.offer(token, tokenid, activeEpoch, msg.sender);

        emit SubmitOffer(token, tokenid, msg.sender, msg.value);
    }

    // function submitOfferSimple(address token) external payable override {

    function submitSwap(
        address token,
        uint256 tokenid,
        uint256 floor,
        bool is1155,
        bool isTraditional
    ) external override {
        _submitSwap(token, tokenid, msg.sender, requestedEpoch, requestedFloor, is1155);
        emit SubmitSwap(token, tokenid, index, account, requestedFloor, epoch);
    }

    function submitClaim(
        address token,
        uint256 tokenid,
        uint256 index
    ) external override {
        emit SubmitClaim(token, tokenid, index, account);
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
