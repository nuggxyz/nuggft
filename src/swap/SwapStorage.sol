// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

import {SwapPure} from './SwapPure.sol';

import {EpochView} from '../epoch/EpochView.sol';

library Swap {
    using SwapPure for uint256;

    struct Full {
        mapping(uint256 => Mapping) map;
    }

    struct Mapping {
        Storage self;
        mapping(uint256 => Storage) items;
    }

    struct Storage {
        uint256 data;
        mapping(uint160 => uint256) offers;
    }

    struct Memory {
        uint256 swapData;
        uint256 offerData;
        uint256 activeEpoch;
        uint160 sender;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TOKEN SWAP
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function _tokenSwapPtr(uint256 tokenId) private view returns (Storage storage si) {
        return Global.ptr().swap.map[tokenId].self;
    }

    function loadTokenSwap(uint256 tokenId, address account) internal view returns (Storage storage s, Memory memory m) {
        s = _tokenSwapPtr(tokenId);
        m = _load(s, uint160(account));
    }

    function deleteTokenOffer(uint256 tokenId, uint160 account) internal {
        delete _tokenSwapPtr(tokenId).offers[account];
    }

    function deleteTokenSwap(uint256 tokenId) internal {
        delete _tokenSwapPtr(tokenId).data;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                ITEM SWAP
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function _itemSwapPtr(uint256 tokenId, uint256 itemId) private view returns (Storage storage si) {
        return Global.ptr().swap.map[tokenId].items[itemId];
    }

    function loadItemSwap(
        uint256 tokenId,
        uint256 itemId,
        uint160 account
    ) internal view returns (Storage storage s, Memory memory m) {
        require(itemId <= 0xffff, 'ML:CI:0');

        s = _itemSwapPtr(tokenId, itemId);
        m = _load(s, account);
    }

    function deleteItemOffer(
        uint256 tokenId,
        uint256 itemId,
        uint160 account
    ) internal {
        delete _itemSwapPtr(tokenId, itemId).offers[account];
    }

    function deleteItemSwap(uint256 tokenId, uint256 itemId) internal {
        delete _itemSwapPtr(tokenId, itemId).data;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                COMMON
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function _load(Storage storage ptr, uint160 account) private view returns (Memory memory m) {
        m.swapData = ptr.data;
        m.activeEpoch = EpochView.activeEpoch();
        m.sender = account;

        if (account == m.swapData.account()) {
            m.offerData = m.swapData;
        } else {
            m.offerData = ptr.offers[account];
        }
    }
}
