// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import './console.sol';

library Print {
    function log(uint256 val, string memory name) internal view {
        console.log('-----------------------');
        console.log('variable: ', name);
        console.log('|', Uint256.toHexString(val, 32), '=', val);
    }

    function log(
        uint256 val0,
        string memory name0,
        uint256 val1,
        string memory name1,
        uint256 val2,
        string memory name2
    ) internal view {
        console.log('-----------------------');
        console.log('variable: ', name0);
        console.log('|', Uint256.toHexString(val0, 32), '=', val0);
        console.log('variable: ', name1);
        console.log('|', Uint256.toHexString(val1, 32), '=', val1);
        console.log('variable: ', name2);
        console.log('|', Uint256.toHexString(val2, 32), '=', val2);
    }

    function log(
        uint256 val0,
        string memory name0,
        uint256 val1,
        string memory name1
    ) internal view {
        console.log('-----------------------');
        console.log(name0, val0, '|', Uint256.toHexString(val0, 32));
        console.log(name1, val1, '|', Uint256.toHexString(val1, 32));
    }

    function log(
        uint256 val0,
        string memory name0,
        uint256 val1,
        string memory name1,
        uint256 val2,
        string memory name2,
        uint256 val3,
        string memory name3
    ) internal view {
        console.log('-----------------------');
        console.log(name0, val0, '|', Uint256.toHexString(val0, 32));
        console.log(name1, val1, '|', Uint256.toHexString(val1, 32));
        console.log(name2, val2, '|', Uint256.toHexString(val2, 32));
        console.log(name3, val3, '|', Uint256.toHexString(val3, 32));
    }

    function log(uint256[] memory arr, string memory name) internal view {
        console.log('--------------------');
        console.log('array: ', name);
        for (uint256 i = 0; i < arr.length; i++) {
            console.log('[', i, ']', Uint256.toHexString(arr[i], 32));
        }
    }
}

library Uint256 {
    bytes16 private constant ALPHABET = '0123456789abcdef';

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toAscii(uint256 value) internal pure returns (bytes memory buffer) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return '0';
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return buffer;
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        return string(toAscii(value));
    }

    /// @notice Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
    /// @dev Credit to Open Zeppelin under MIT license https://github.com/OpenZeppelin/openzeppelin-contracts/blob/243adff49ce1700e0ecb99fe522fb16cff1d1ddc/contracts/utils/Strings.sol#L55
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        require(value == 0, 'Strings: hex length insufficient');
        return string(buffer);
    }

    function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length);
        for (uint256 i = buffer.length; i > 0; i--) {
            buffer[i - 1] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}

// library Event {
//     function log(uint256 val, string memory name) internal view {}

//     function log(
//         uint256 val0,
//         string memory name0,
//         uint256 val1,
//         string memory name1,
//         uint256 val2,
//         string memory name2
//     ) internal view {}

//     function log(uint256[] memory arr, string memory name) internal view {}
// }
