// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

/*
 * @dev Uint operations.
 */
library strings {
    bytes16 private constant ALPHABET = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toAsciiString(uint256 value) internal pure returns (string memory) {
        return string(toAsciiBytes(value));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toAsciiBytes(uint256 value) internal pure returns (bytes memory buffer) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
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
    function toHexString(address value) internal pure returns (string memory) {
        return toHexString(uint256(uint160(value)), 20);
    }

    /// @notice Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
    /// @dev Credit to Open Zeppelin under MIT license https://github.com/OpenZeppelin/openzeppelin-contracts/blob/243adff49ce1700e0ecb99fe522fb16cff1d1ddc/contracts/utils/Strings.sol#L55
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
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
