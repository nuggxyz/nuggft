// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ISwapExternal} from '../interfaces/nuggft/ISwapExternal.sol';

import {EpochCore} from '../epoch/EpochCore.sol';

import {Swap} from './SwapStorage.sol';
import {SwapCore} from './SwapCore.sol';

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

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function verifedDelegateMin(uint160 tokenId) external view override returns (uint96 amount) {
        return SwapCore.verifedDelegateMin(tokenId);
    }
}
