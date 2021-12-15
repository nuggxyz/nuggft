// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/ShiftLib.sol';

import '../libraries/SSTORE2.sol';

import '../_test/utils/Print.sol';

import './VaultShiftLib.sol';

library Vault {
    using VaultShiftLib for uint256;

    struct Storage {
        mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) files;
        uint256 lengthData;
        uint256[] ptrs;
    }

    function decoder(bytes memory data, uint256 feature) internal pure returns (uint256[][] memory res) {
        bytes[] memory tmp = abi.decode((data), (bytes[]));
        res = abi.decode(tmp[feature], (uint256[][]));
    }

    function set(Storage storage s, uint256[][][] calldata data) internal {
        require(data.length <= 8 && data.length > 0, 'VAULT:FEAT:0');

        bytes[] memory a = new bytes[](8);

        uint256 ptr;

        for (uint256 i = 0; i < data.length; i++) {
            ptr = ptr.length(i, data[i].length);
            a[i] = abi.encode(data[i]);
        }

        ptr = ptr.addr(SSTORE2.write(abi.encode(a)));

        s.ptrs.push(ptr);

        s.lengthData = s.lengthData.addLengths(ptr);
    }

    function get(
        Storage storage s,
        uint256 feature,
        uint256 id
    ) internal view returns (uint256[] memory data) {
        uint256 pointer;
        uint256 cumItems;

        for (uint256 i = 0; i < s.ptrs.length; i++) {
            pointer = s.ptrs[i];
            cumItems += pointer.length(feature);
            if (cumItems > id) break;
            else if (s.ptrs.length == i + 1) require(false, "VAULT:GET:1");
            id -= pointer.length(feature);
        }

        data = abi.decode(abi.decode(SSTORE2.read(pointer.addr()), (bytes[]))[feature], (uint256[][]))[id];

    }

    function getBatch(Storage storage s, uint256[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            data[i] = get(s, ids[i] >> 12, ids[i] & ShiftLib.mask(12));
        }
    }
}

// function set(Storage storage s, uint256[][] memory data) internal {
//     // require(feature < 8, 'VAULT:FEAT:0');'

//     uint256 lengths = s.lengthData;

//     for (uint256 i = 0; i < data.length; i++) {
//         uint256 feature = VaultShiftLib.getFeature(data[i]);

//         uint256 len;

//         (lengths, len) = VaultShiftLib.incrementLengthOf(lengths, feature);

//         for (uint256 j = 0; j < data[i].length; j++) {
//             s.files[feature][len - 1][j] = data[i][j];
//         }
//     }

//     s.lengthData = lengths;
// }

// function get(
//     Storage storage s,
//     uint256 feature,
//     uint256 id
// ) internal view returns (uint256[] memory data) {
//     uint256 zero = s.files[feature][id][0];

//     uint256 length = VaultShiftLib.getDataLength(zero);

//     data = new uint256[](length);

//     for (uint256 i = 0; i < length; i++) {
//         data[i] = s.files[feature][id][i];
//     }
// }
