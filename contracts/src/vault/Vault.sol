// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/ShiftLib.sol';
import '../../tests/Event.sol';
library Vault {
    struct Storage {
        mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) items;
        uint256 lengthData;
    }

    function set(Storage storage s, uint256[][] memory data) internal {
        // require(feature < 8, 'VAULT:FEAT:0');'

        uint256 lengths = s.lengthData;

        for (uint256 i = 0; i < data.length; i++) {
            uint256 feature = getFeature(data[i]);

            uint256 len;

            (lengths, len) = incrementLengthOf(lengths, feature);

            for (uint256 j = 0; j < data[i].length; j++) {
                s.items[feature][len - 1][j] = data[i][j];
            }
        }

        s.lengthData = lengths;
    }

    function get(
        Storage storage s,
        uint256 feature,
        uint256 id
    ) internal view returns (uint256[] memory data) {
        uint256 zero = s.items[feature][id][0];

        uint256 length = getDataLength(zero);
        Event.log(zero, "zero", length, "length", id, "id");

        data = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            data[i] = s.items[feature][id][i];
        }
    }

    function getBatch(Storage storage s, uint256[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            data[i] = get(s, ids[i] >> 12, ids[i] & ShiftLib.mask(12));
        }
    }

    function getDataLength(uint256 data) internal pure returns (uint256 res) {
        res = (data >> 250);
    }

    function setDataLength(uint256 lengthData, uint256 feature) internal pure returns (uint256 res) {
        res = (lengthData >> (12 * feature)) & ShiftLib.mask(12);
    }

    function getFeature(uint256[] memory data) internal pure returns (uint256 res) {
        res = (data[data.length - 1] >> 32) & 0x7;
    }

    function getLengthOf(uint256 lengthData, uint256 feature) internal pure returns (uint256 res) {
        res = (lengthData >> (12 * feature)) & ShiftLib.mask(12);
    }

    function incrementLengthOf(uint256 lengthData, uint256 feature) internal pure returns (uint256 res, uint256 update) {
        update = getLengthOf(lengthData, feature) + 1;

        res = lengthData & ShiftLib.fullsubmask(12, 12 * feature);

        res |= (update << (12 * feature));
    }
}
