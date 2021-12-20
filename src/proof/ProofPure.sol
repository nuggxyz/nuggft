// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {FilePure} from '../file/FilePure.sol';

// import {Print} from '../_test/utils/Print.sol';

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

        require(arr[feat] == 0, 'PP:0');

        arr[feat] = pos;

        res = ShiftLib.setArray(input, 64, arr);
    }

    function pullFromExtra(uint256 input, uint16 itemId) internal pure returns (uint256 res) {
        uint8[] memory arr = ShiftLib.getArray(input, 64);

        (uint8 feat, uint8 pos) = parseItemId(itemId);

        require(arr[feat] == pos, 'PP:1');

        arr[feat] = 0;

        res = ShiftLib.setArray(input, 64, arr);
    }

    function rotateDefaultandExtra(uint256 input, uint8 feature) internal pure returns (uint256 res) {
        uint8[] memory def = ShiftLib.getArray(input, 0);
        uint8[] memory ext = ShiftLib.getArray(input, 64);

        uint8 tmp = ext[feature];
        ext[feature] = def[feature];
        def[feature] = tmp;

        res = ShiftLib.setArray(input, 0, def);
        res = ShiftLib.setArray(res, 64, ext);
    }

    function setNewAnchorOverrides(
        uint256 input,
        uint8[] memory xs,
        uint8[] memory ys
    ) internal pure returns (uint256 res) {
        res = ShiftLib.setArray(input, 128, xs);
        res = ShiftLib.setArray(res, 192, ys);
    }

    function clearAnchorOverridesForFeature(uint256 input, uint8 feature) internal pure returns (uint256 res) {
        uint8[] memory x = ShiftLib.getArray(input, 128);
        uint8[] memory y = ShiftLib.getArray(input, 192);

        y[feature] = 0;
        x[feature] = 0;

        res = ShiftLib.setArray(input, 128, x);
        res = ShiftLib.setArray(res, 192, y);
    }

    function parseItemId(uint16 itemId) internal pure returns (uint8 feat, uint8 pos) {
        feat = uint8(itemId >> 8);
        pos = uint8(itemId & 0xff);
    }
}
