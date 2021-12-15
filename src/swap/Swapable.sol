// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../token/Token.sol';
import './Swap.sol';
import './SwapLib.sol';
import './SwapItemLib.sol';

import '../interfaces/INuggFT.sol';

abstract contract Swapable is ISwapable {
    function genesis() public view virtual override returns (uint256);

    function nuggft() internal view virtual returns (Token.Storage storage);

    using SwapShiftLib for uint256;
    using EpochLib for uint256;

    using Swap for Swap.Storage;

    using SwapLib for Token.Storage;
    using SwapItemLib for Token.Storage;

    constructor() {}

    function getActiveSwap(uint256 tokenid)
        external
        view
        override
        returns (
            address leader,
            uint256 amount,
            uint256 _epoch,
            bool isOwner
        )
    {
        (uint256 swapData, ) = nuggft()._swaps[tokenid].self.loadStorage(address(0));
        require(swapData != 0, 'NS:GS:0');
        leader = address(swapData.account());
        amount = swapData.eth();
        _epoch = swapData.epoch();
        isOwner = swapData.isOwner();
    }

    function getOfferByAccount(
        uint256 tokenid,
        uint256 index,
        address account
    ) external view override returns (uint256 amount) {
        (, uint256 offerData) = nuggft()._swaps[tokenid].self.loadStorage(account, index);
        require(offerData != 0, 'NS:GS:0');
        amount = offerData.eth();
    }

    function epoch() external view override returns (uint256 res) {
        res = genesis().activeEpoch();
    }

    function delegate(uint256 tokenid) external payable override {
        nuggft().delegate(genesis(), tokenid);
    }

    function mint(uint256 tokenid) external payable override {
        nuggft().mint(genesis(), tokenid);
    }

    function delegateItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external payable override {
        nuggft().delegateItem(genesis(), sellingTokenId, itemid, uint160(buyingTokenId));
    }

    function commit(uint256 tokenid) external payable override {
        nuggft().commit(genesis(), tokenid);
    }

    function commitItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external payable override {
        nuggft().commitItem(genesis(), sellingTokenId, itemid, uint160(buyingTokenId));
    }

    function offer(uint256 tokenid) external payable override {
        nuggft().offer(genesis(), tokenid);
    }

    function offerItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external payable override {
        nuggft().offerItem(genesis(), sellingTokenId, itemid, uint160(buyingTokenId));
    }

    function claim(uint256 tokenid, uint256 endingEpoch) external override {
        nuggft().claim(genesis(), tokenid, endingEpoch);
    }

    function claimItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId,
        uint256 endingEpoch
    ) external override {
        nuggft().claimItem(genesis(), sellingTokenId, itemid, endingEpoch, uint160(buyingTokenId));
    }

    function swap(uint256 tokenid, uint256 floor) external override {
        nuggft().swap(tokenid, floor);
    }

    function swapItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 floor
    ) external override {
        nuggft().swapItem(itemid, floor, uint160(sellingTokenId));
    }
}
