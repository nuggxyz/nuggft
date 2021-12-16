// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ISwapExternal} from '../interfaces/INuggFT.sol';

import {SwapView} from './view.sol';

abstract contract SwapExternal is ISwapExternal {
    function getActiveSwap(uint256 tokenId)
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
        return SwapView.getActiveSwap(tokenId);
    }

    function getOfferByAccount(
        uint256 tokenId,
        uint256 index,
        address account
    ) external view override returns (uint256 amount) {
        return SwapView.getOfferByAccount(tokenId, index, account);
    }

    function epoch() external view override returns (uint256 res) {
        res = EpochView.activeEpoch();
    }

    function delegate(uint256 tokenId) external payable override {
        SwapLogic.delegate(tokenId);
    }

    function delegateItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external payable override {
        SwapLogic.delegateItem(sellingTokenId, itemid, uint160(buyingTokenId));
    }

    function claim(uint256 tokenId, uint256 endingEpoch) external override {
        SwapLogic.claim(tokenId, endingEpoch);
    }

    function claimItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId,
        uint256 endingEpoch
    ) external override {
        SwapLogic.claimItem(sellingTokenId, itemid, endingEpoch, uint160(buyingTokenId));
    }

    function swap(uint256 tokenId, uint256 floor) external override {
        SwapLogic.swap(tokenId, floor);
    }

    function swapItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 floor
    ) external override {
        SwapLogic.swapItem(itemid, floor, uint160(sellingTokenId));
    }
}
