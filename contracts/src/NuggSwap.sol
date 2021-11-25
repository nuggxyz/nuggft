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

    IxNUGG public override xnugg;

    constructor(address _xnugg) {
        xnugg = IxNUGG(_xnugg);
    }

    function submitOffer(
        address token,
        uint256 tokenid,
        uint256 index
    ) external payable override {
        _submitOffer(token, tokenid, index, msg.sender, msg.value);
    }

    function submitOfferSimple(address token) external payable override {
        _submitOffer(token, EpochLib.activeEpoch(), 0, msg.sender, msg.value);
    }

    function submitSwap(
        address token,
        uint256 tokenid,
        uint256 index,
        uint48 requestedEpoch,
        uint128 requestedFloor
    ) external override {
        _submitSwap(token, tokenid, index, msg.sender, requestedEpoch, requestedFloor);
    }

    function submitClaim(
        address token,
        uint256 tokenid,
        uint256 index
    ) external override {
        _submitClaim(token, tokenid, index, msg.sender, msg.sender);
    }

    function submitClaimSimple(address token, uint256 epoch) external override {
        _submitClaim(token, epoch, 0, msg.sender, msg.sender);
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

    function _submitOffer(
        address token,
        uint256 tokenid,
        uint256 index,
        address account,
        uint256 value
    ) internal {
        (SwapLib.Storage storage s, uint256 swapData, uint256 offerData) = SwapLib.loadStorage(
            token,
            tokenid,
            account,
            index
        );

        uint256 activeEpoch = EpochLib.activeEpoch();

        uint256 newSwapData;

        require(swapData != 0 || index == 0);

        // if swap exists
        if (swapData != 0) {
            // make sure user is not the owner of swap
            require(!offerData.isOwner(), 'SL:HSO:0');

            // make sure swap is still active
            require(activeEpoch <= swapData.epoch(), 'SL:OBP:3');

            // save prev users data
            s.users[index][swapData.addr()] = swapData;

            // copy relevent items from swapData to newSwapData
            newSwapData = newSwapData.setEpoch(swapData.epoch());
        } else if (index == 0) {
            // attempt to mint token - reverts if it cannot
            // checks if nuggswap already owns token
            SwapLib.mintToken(token, activeEpoch);

            // set relevent data to newSwapData
            newSwapData = newSwapData.setEpoch(activeEpoch);
        }

        // set
        (newSwapData, ) = newSwapData.setAccount(account).setEth(offerData.eth() + value);

        require(swapData.eth().pointsWith(100) < newSwapData.eth(), 'SL:OBP:4');

        s.datas[index] = newSwapData;

        address(xnugg).sendValue(newSwapData.eth() - swapData.eth());

        emit SubmitOffer(token, tokenid, index, account, value);
    }

    function _submitClaim(
        address token,
        uint256 tokenid,
        uint256 index,
        address account,
        address to
    ) internal {
        (SwapLib.Storage storage s, uint256 swapData, uint256 offerData) = SwapLib.loadStorage(
            token,
            tokenid,
            account,
            index
        );

        uint256 activeEpoch = EpochLib.activeEpoch();

        bool winner;

        winner = SwapLib.checkClaimer(account, swapData, offerData, activeEpoch);

        delete s.users[index][account];

        if (winner) {
            SwapLib.moveERC721(token, tokenid, address(this), to);
            delete s.datas[index];
        } else {
            to.sendValue(offerData.eth());
        }

        emit SubmitClaim(token, tokenid, index, account);
    }

    function _submitSwap(
        address token,
        uint256 tokenid,
        uint256 index,
        address account,
        uint48 requestedEpoch,
        uint256 requestedFloor
    ) internal {
        // only minting swaps can be numbered 0
        require(index > 0, 'NS:SS:-1');

        (SwapLib.Storage storage s, uint256 swapData, ) = SwapLib.loadStorage(token, tokenid, account, index);

        // make sure swap does not exist
        require(swapData == 0, 'NS:SS:0');

        // force swaps to be started in sequential order
        if (index != 1) require(s.datas[index - 1] != 0, 'NS:SS:1');

        // calculate epoch
        uint256 epoch = EpochLib.activeEpoch() + requestedEpoch;

        // build starting swap data
        (swapData, ) = swapData.setAccount(account).setEpoch(epoch).setIsOwner().setEth(requestedFloor);

        SwapLib.moveERC721(token, tokenid, account, address(this));

        // sstore swapdata
        s.datas[index] = swapData;

        emit SubmitSwap(token, tokenid, index, account, requestedFloor, epoch);
    }
}
