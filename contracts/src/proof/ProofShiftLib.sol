// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/ShiftLib.sol';

import '../vault/VaultShiftLib.sol';

import '../../tests/Event.sol';

library ProofShiftLib {
    using ShiftLib for uint256;

    uint256 constant ID_SIZE = 16;
    uint256 constant ID_FEATURE_SIZE = 4;
    uint256 constant ID_NUMBER_SIZE = 12;

    uint256 constant FEATURE_ARR_SIZE = 8;

    uint256 constant DISPLAY_ARRAY_POSITION = 0;
    uint256 constant DISPLAY_ARRAY_MAX_LEN = 8;
    uint256 constant DIAPLAY_ARRAY_ITEM_BIT_LEN = 16;

    function initFromSeed(uint256 lengthData, uint256 seed) internal view returns (uint256 res) {
        require(seed != 0, 'seed');

        uint256[] memory upd = new uint256[](4);

        uint256 pick0 = ((seed >> (4 + ID_SIZE * 0)) & ShiftLib.mask(ID_NUMBER_SIZE)) % VaultShiftLib.length(lengthData, 0);
        uint256 pick1 = ((seed >> (4 + ID_SIZE * 1)) & ShiftLib.mask(ID_NUMBER_SIZE)) % VaultShiftLib.length(lengthData, 1);
        uint256 pick2 = ((seed >> (4 + ID_SIZE * 2)) & ShiftLib.mask(ID_NUMBER_SIZE)) % VaultShiftLib.length(lengthData, 2);

        uint256 pick3 = (seed >> 69) % 256;

        uint256 num = (seed >> (4 + ID_SIZE * 3)) & ShiftLib.mask(ID_NUMBER_SIZE);

        if (pick3 < 96) {
            pick3 = (3 << ID_NUMBER_SIZE) | (num % (VaultShiftLib.length(lengthData, 3)));
        } else if (pick3 < 192) {
            pick3 = (4 << ID_NUMBER_SIZE) | (num % (VaultShiftLib.length(lengthData, 4)));
        } else if (pick3 < 250) {
            pick3 = (5 << ID_NUMBER_SIZE) | (num % (VaultShiftLib.length(lengthData, 5)));
        } else {
            pick3 = (6 << ID_NUMBER_SIZE) | (num % (VaultShiftLib.length(lengthData, 6)));
        }
        // pick1 |= 1 << ID_NUMBER_SIZE;
        // pick2 |= 2 << ID_NUMBER_SIZE;

        upd[0] = pick0;
        upd[1] = pick1 | (1 << ID_NUMBER_SIZE);
        upd[2] = pick2 | (2 << ID_NUMBER_SIZE);
        upd[3] = pick3;

        res = ShiftLib.setDynamicArray(res, upd, 16, 0, 4, 8);

        // Event.log(res, 'res');

        // res = (pick3 << (3 * ID_SIZE + 4)) | (pick2 << (2 * ID_SIZE + 4)) | (pick1 << (1 * ID_SIZE + 4)) | (pick0 << 4) | 4;
    }

    function parseProofLogic(uint256 _proof)
        internal
        view
        returns (
            uint256 proof,
            uint256[] memory defaultIds,
            uint256[] memory extraIds,
            uint256[] memory overrides
        )
    {
        proof = _proof;

        // Event.log(proof, 'proof');

        (defaultIds, , ) = ShiftLib.getDynamicArray(proof, 16, 0);

        Event.log(defaultIds, "defaultIds");

        // for (uint256 i = 0; i < defaultIds.length; i++) {
        //     defaultIds[i] = _proof.get(16, 4 + i * 16);
        // }
        // extraIds = new uint256[](8);
        // overrides = new uint256[](8);
    }

    // function size(uint256 input, uint256 update) internal view returns (uint256 res) {
    //     res = ShiftLib.set(input, 4, 0, update);
    // }

    // function size(uint256 input) internal view returns (uint256 res) {
    //     res = ShiftLib.get(input, 4, 0);
    // }

    function items(uint256 input) internal view returns (uint256[] memory res) {
        (res, , ) = ShiftLib.getDynamicArray(input, 16, 0);
    }

    // function pushItem(
    //     uint256 input,
    //     uint16 itm,
    //     uint8 at
    // ) internal view returns (uint256 res) {
    //     // Shift
    //     // assembly {
    //     //     let offset := add(4, mul(16, at))
    //     //     res := and(input, not(shl(offset, 0xffff)))
    //     //     res := or(input, shl(offset, itm))
    //     // }
    // }

    // function popItem(uint256 input, uint8 at) internal view returns (uint256 res, uint16 itm) {
    //     // assembly {
    //     //     let offset := add(4, mul(16, at))
    //     //     res := and(input, not(shl(offset, 0xffff)))
    //     //     itm := shr(offset, input)
    //     // }
    // }

    function push(uint256 input, uint256 itemId) internal view returns (uint256 res) {
        res = ShiftLib.pushDynamicArray(input, 16, 0, itemId);
        // uint256[] memory _items = items(input);
        // for (uint8 i = 0; i < _items.length; i++) {
        //     if (_items[i] == 0) {
        //         index = i + 1;
        //         break;
        //     }
        // }

        // require(index > 0, 'SL:PFM:A');

        // index--;

        // res = pushItem(input, itemId, index);
    }

    function pop(uint256 input, uint256 itemId)
        internal
        view
        returns (
            uint256 res // uint16 popped,
        )
    // uint8 index
    {
        res = ShiftLib.popDynamicArray(input, 16, 0, itemId);
        // uint256[] memory _items = items(input);

        // for (uint8 i = 0; i < _items.length; i++) {
        //     if (_items[i] == itemId) {
        //         index = i + 1;
        //         break;
        //     }
        // }

        // require(index > 0, 'SL:PFM:0');

        // index--;

        // (res, popped) = popItem(input, index);

        // require(popped == itemId, 'SL:PFM:1');
    }
}

// 1.5 x each feature for a coordinate (0.75 x 2)
// 2 byte each feature for expanders coordinate (16, 16, 16, 16)
// 1 byte each feature for expanders amount (4, 4, 4, 4)

// 3 | 1/2 bytes - base ---- 8 | .5 --- 8 | .5   ---- 1 vars

// 8 | 1 bytes - head
// 8 | 1 bytes - eyes
// 8 | 1 bytes - mouth
// 8 | 1 bytes - back
// 8 | 1 bytes - hair
// 8 | 1 bytes - neck ---- 48 | 6 --- 51 | 6.5    ----- 6 vars

// 8 | 1 bytes - head
// 8 | 1 bytes - eyes
// 8 | 1 bytes - mouth
// 8 | 1 bytes - back
// 8 | 1 bytes - hair
// 8 | 1 bytes - neck ---- 48 | 6  -- 99 | 12.5 ---- 6 vars

// 12 | 1.5 bytes - head coordinate
// 12 | 1.5 bytes - eyes coordinate
// 12 | 1.5 bytes - mouth coordinate
// 12 | 1.5 bytes - back coordinate
// 12 | 1.5 bytes - hair coordinate
// 12 | 1.5 bytes - neck coordinate ---- 159-    ----- 12 vars

// 3            - expander 3 feat      ------- 3 vars

// 3            - expander 1 feat
// 24 | 3 bytes - expander 1
// 3            - expander 2 feat
// 24 | 3 bytes - expander 2
// 24 | 3 bytes - expander 3       - 24 vars
