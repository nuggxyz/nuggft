// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

import {SwapPure} from './SwapPure.sol';

import {EpochCore} from '../epoch/EpochCore.sol';

// SYSTEM TEST
library Swap {
    using SwapPure for uint256;

    struct Full {
        mapping(uint160 => Mapping) map;
    }

    struct Mapping {
        Storage self;
        mapping(uint16 => Storage) items;
    }

    struct Storage {
        uint256 data;
        mapping(uint160 => uint256) offers;
    }

    struct Memory {
        uint256 swapData;
        uint256 offerData;
        uint32 activeEpoch;
        uint160 sender;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TOKEN SWAP
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function _tokenSwapPtr(uint160 tokenId) private view returns (Storage storage si) {
        return Global.ptr().swap.map[tokenId].self;
    }

    function loadTokenSwap(uint160 tokenId, address account) internal view returns (Storage storage s, Memory memory m) {
        s = _tokenSwapPtr(tokenId);
        m = _load(s, uint160(account));
    }

    function deleteTokenOffer(uint160 tokenId, uint160 account) internal {
        delete _tokenSwapPtr(tokenId).offers[account];
    }

    function deleteTokenSwap(uint160 tokenId) internal {
        delete _tokenSwapPtr(tokenId).data;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                ITEM SWAP
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function _itemSwapPtr(uint160 tokenId, uint16 itemId) private view returns (Storage storage si) {
        return Global.ptr().swap.map[tokenId].items[itemId];
    }

    function loadItemSwap(
        uint160 tokenId,
        uint16 itemId,
        uint160 account
    ) internal view returns (Storage storage s, Memory memory m) {
        s = _itemSwapPtr(tokenId, itemId);
        m = _load(s, account);
    }

    function deleteItemOffer(
        uint160 tokenId,
        uint16 itemId,
        uint160 account
    ) internal {
        delete _itemSwapPtr(tokenId, itemId).offers[account];
    }

    function deleteItemSwap(uint160 tokenId, uint16 itemId) internal {
        delete _itemSwapPtr(tokenId, itemId).data;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                COMMON
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function _load(Storage storage ptr, uint160 account) private view returns (Memory memory m) {
        uint256 cache = ptr.data;
        m.swapData = cache;
        m.activeEpoch = EpochCore.activeEpoch();
        m.sender = account;

        if (account == cache.account()) {
            m.offerData = cache;
        } else {
            m.offerData = ptr.offers[account];
        }
    }
}
