// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ISwapExternal} from '../interfaces/INuggFT.sol';

import {SwapCore} from './core.sol';
import {SwapView} from './view.sol';
import {Swap} from './storage.sol';
import {EpochView} from '../epoch/view.sol';

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

    function getOfferByAccount(uint256 tokenId, address account) external view override returns (uint256 amount) {
        return SwapView.getOfferByAccount(tokenId, account);
    }

    function delegate(uint256 tokenId) external payable override {
        SwapCore.delegate(tokenId);
    }

    function delegateItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external payable override {
        SwapCore.delegateItem(sellingTokenId, itemid, uint160(buyingTokenId));
    }

    function claim(uint256 tokenId) external override {
        SwapCore.claim(tokenId);
    }

    function claimItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 buyingTokenId
    ) external override {
        SwapCore.claimItem(sellingTokenId, itemid, uint160(buyingTokenId));
    }

    function swap(uint256 tokenId, uint256 floor) external override {
        SwapCore.swap(tokenId, floor);
    }

    function swapItem(
        uint256 sellingTokenId,
        uint256 itemid,
        uint256 floor
    ) external override {
        SwapCore.swapItem(itemid, floor, uint160(sellingTokenId));
    }
}
