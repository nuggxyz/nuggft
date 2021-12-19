// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {FilePure} from '../file/FilePure.sol';
import {Print} from '../_test/utils/Print.sol';

library ProofPure {
    using ShiftLib for uint256;

    function fullProof(uint256 input)
        internal
        pure
        returns (
            uint256 proof,
            uint8[] memory defaultIds,
            uint8[] memory extraIds,
            uint8[] memory overxs,
            uint8[] memory overys
        )
    {
        proof = input;
        defaultIds = ShiftLib.getArray(proof, 0);
        extraIds = ShiftLib.getArray(proof, 64);
        overxs = ShiftLib.getArray(proof, 128);
        overys = ShiftLib.getArray(proof, 192);
    }

    function pushToExtra(uint256 input, uint16 itemId) internal pure returns (uint256 res) {
        uint8[] memory arr = ShiftLib.getArray(input, 64);

        (uint8 feat, uint8 pos) = parseItemId(itemId);

        // Print.log(feat, 'feat', pos, 'pos', arr[feat], 'arr[feat]');
        // Print.log(arr, 'arr');

        require(arr[feat] == 0, 'PP:0');

        arr[feat] = pos;

        return ShiftLib.setArray(input, 64, arr);
    }

    function pullFromExtra(uint256 input, uint16 itemId) internal pure returns (uint256 res) {
        uint8[] memory arr = ShiftLib.getArray(input, 64);

        (uint8 feat, uint8 pos) = parseItemId(itemId);

        // Print.log(feat, 'feat', pos, 'pos', arr[feat], 'arr[feat]');
        // Print.log(arr, 'arr');

        require(arr[feat] == pos, 'PP:1');

        arr[feat] = 0;

        res = ShiftLib.setArray(input, 64, arr);
    }

    function rotateDefaultandExtra(uint256 input, uint8 feature) internal pure returns (uint256 res) {
        uint8[] memory def = ShiftLib.getArray(input, 0);
        uint8[] memory ext = ShiftLib.getArray(input, 64);

        // Print.log(def, 'def');
        // Print.log(ext, 'ext');

        uint8 tmp = ext[feature];
        ext[feature] = def[feature];
        def[feature] = tmp;

        // Print.log(def, 'def');
        // Print.log(ext, 'ext');

        res = ShiftLib.setArray(input, 0, def);
        res = ShiftLib.setArray(res, 64, ext);
    }

    function setOverride(
        uint256 input,
        uint8[] memory xs,
        uint8[] memory ys
    ) internal pure returns (uint256 res) {
        res = ShiftLib.setArray(input, 128, xs);
        res = ShiftLib.setArray(res, 192, ys);
    }

    function parseItemId(uint16 itemId) internal pure returns (uint8 feat, uint8 pos) {
        feat = uint8(itemId >> 8);
        pos = uint8(itemId & 0xff);
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
