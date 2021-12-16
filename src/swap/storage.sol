// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SwapPure} from './pure.sol';

import {Global} from '../global/storage.sol';

import {EpochView} from '../epoch/view.sol';

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

    /*///////////////////////////////////////////////////////////////
                            TOKEN SWAP LOADERS
    //////////////////////////////////////////////////////////////*/

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

    // function loadTokenSwapWithEpoch(
    //     uint256 tokenId,
    //     address account,
    //     uint256 epoch
    // ) internal  returns (Storage storage s, Memory memory m) {
    //     s = _tokenSwapPtr(tokenId);
    //     m = _loadWithEpoch(s, uint160(account), epoch);
    // }

    /*///////////////////////////////////////////////////////////////
                            ITEM SWAP LOADERS
    //////////////////////////////////////////////////////////////*/

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

    // function loadItemSwapWithEpoch(
    //     uint256 tokenId,
    //     uint256 itemId,
    //     uint160 account,
    //     uint256 epoch
    // ) internal  returns (Storage storage s, Memory memory m) {
    //     s = _itemSwapPtr(tokenId, itemId);
    //     m = _loadWithEpoch(s, account, epoch);
    // }

    /*///////////////////////////////////////////////////////////////
                                COMMON
    //////////////////////////////////////////////////////////////*/

    function _load(Storage storage ptr, uint160 account) private view returns (Memory memory m) {
        m.swapData = ptr.data;
        m.activeEpoch = EpochView.activeEpoch();
        m.sender = account;
        // if (m.swapData == 0) return m;

        if (account == m.swapData.account()) {
            m.offerData = m.swapData;
        } else {
            m.offerData = ptr.offers[account];
        }
    }

    // function _loadWithEpoch(
    //     Storage storage ptr,
    //     uint160 account,
    //     uint256 epoch
    // ) private  returns (Memory memory m) {
    //     m.swapData = ptr.self.data;

    //     m.activeEpoch = EpochView.activeEpoch();

    //     if (m.swapData.epoch() != epoch) m.swapData = 0;

    //     if (m.swapData != 0 && account == m.swapData.account()) {
    //         m.offerData = m.swapData;
    //     } else {
    //         m.offerData = ptr.offers[account];
    //     }
    // }
}
