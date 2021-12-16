// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {VaultPure} from '../vault/pure.sol';

import '../_test/utils/Print.sol';

library ProofPure {
    using ShiftLib for uint256;

    uint256 constant ID_SIZE = 16;
    uint256 constant ID_FEATURE_SIZE = 4;
    uint256 constant ID_NUMBER_SIZE = 12;

    uint256 constant FEATURE_ARR_SIZE = 8;

    uint256 constant DISPLAY_ARRAY_POSITION = 0;
    uint256 constant DISPLAY_ARRAY_MAX_LEN = 8;
    uint256 constant DIAPLAY_ARRAY_ITEM_BIT_LEN = 16;

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

        // Print.log(proof, 'proof');

        (defaultIds, , ) = ShiftLib.getDynamicArray(proof, 16, 0);

        // Print.log(defaultIds, 'defaultIds');
    }

    function items(uint256 input) internal view returns (uint256[] memory res) {
        (res, , ) = ShiftLib.getDynamicArray(input, 16, 0);
    }

    function push(uint256 input, uint256 itemId) internal view returns (uint256 res) {
        res = ShiftLib.pushDynamicArray(input, 16, 0, itemId);
    }

    function pop(uint256 input, uint256 itemId) internal view returns (uint256 res) {
        res = ShiftLib.popDynamicArray(input, 16, 0, itemId);
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
