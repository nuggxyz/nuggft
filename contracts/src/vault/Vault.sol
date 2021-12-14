// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/ShiftLib.sol';

import './VaultShiftLib.sol';

library Vault {
    struct Storage {
        mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) files;
        uint256 lengthData;
    }

    function set(Storage storage s, uint256[][] memory data) internal {
        // require(feature < 8, 'VAULT:FEAT:0');'

        uint256 lengths = s.lengthData;

        for (uint256 i = 0; i < data.length; i++) {
            uint256 feature = VaultShiftLib.getFeature(data[i]);

            uint256 len;

            (lengths, len) = VaultShiftLib.incrementLengthOf(lengths, feature);

            for (uint256 j = 0; j < data[i].length; j++) {
                s.files[feature][len - 1][j] = data[i][j];
            }
        }

        s.lengthData = lengths;
    }

    function get(
        Storage storage s,
        uint256 feature,
        uint256 id
    ) internal view returns (uint256[] memory data) {
        uint256 zero = s.files[feature][id][0];

        uint256 length = VaultShiftLib.getDataLength(zero);

        data = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            data[i] = s.files[feature][id][i];
        }
    }

    function getBatch(Storage storage s, uint256[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            data[i] = get(s, ids[i] >> 12, ids[i] & ShiftLib.mask(12));
        }
    }
}
