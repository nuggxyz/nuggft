// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ISwapExternal} from '../interfaces/INuggFT.sol';

import {EpochCore} from '../epoch/EpochCore.sol';

import {Swap} from './SwapStorage.sol';
import {SwapCore} from './SwapCore.sol';
import {SwapView} from './SwapView.sol';

// OK
abstract contract SwapExternal is ISwapExternal {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function delegate(uint160 tokenId) external payable override {
        SwapCore.delegate(tokenId);
    }

    function delegateItem(
        uint160 sellingTokenId,
        uint16 itemid,
        uint160 buyingTokenId
    ) external payable override {
        SwapCore.delegateItem(sellingTokenId, itemid, buyingTokenId);
    }

    function claim(uint160 tokenId) external override {
        SwapCore.claim(tokenId);
    }

    function claimItem(
        uint160 sellingTokenId,
        uint16 itemid,
        uint160 buyingTokenId
    ) external override {
        SwapCore.claimItem(sellingTokenId, itemid, buyingTokenId);
    }

    function swap(uint160 tokenId, uint96 floor) external override {
        SwapCore.swap(tokenId, floor);
    }

    function swapItem(
        uint160 sellingTokenId,
        uint16 itemid,
        uint96 floor
    ) external override {
        SwapCore.swapItem(itemid, floor, sellingTokenId);
    }

    // function delegate2(uint160 tokenId) external payable {
    //     SwapCore.delegate(tokenId);
    // }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function getActiveSwap(uint160 tokenId)
        external
        view
        override
        returns (
            address leader,
            uint96 amount,
            uint32 _epoch,
            bool isOwner
        )
    {
        return SwapView.getActiveSwap(tokenId);
    }

    function getOfferByAccount(uint160 tokenId, address account) external view override returns (uint96 amount) {
        return SwapView.getOfferByAccount(tokenId, account);
    }
}
