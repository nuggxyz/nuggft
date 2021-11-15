// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IDotNugg.sol';
import 'hardhat/console.sol';

/**
 * @title Base64
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice library for encoding bytes into base64
 */
library Base64 {
    string internal constant _TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    string internal constant _BASE64_PREFIX_JSON = 'data:application/json;base64,';
    string internal constant _BASE64_PREFIX_DOTNUGG = 'data:image/dotnugg;base64,';
    string internal constant _BASE64_PREFIX_SVGs = 'data:image/svg+xml;base64,';

    /**
     * @notice wrapper for _encode for svg data
     * @param data bytes to encode
     * @return base64 string representation of input bytes, prefixed with json base64 prefix
     */
    function encode(bytes memory data, string memory file) internal view returns (string memory) {
        return string(abi.encodePacked('data:', file, ';base64,', _encode(data)));
    }

    /**
     * @notice Encodes some bytes in base64
     * @param data bytes to encode
     * @return base64 string representation of input bytes
     * @dev Credit to Brecht Devos - <brecht@loopring.org> - under MIT license https://github.com/Brechtpd/base64/blob/main/base64.sol
     * @dev modified for solidity v8
     */
    function _encode(bytes memory data) private view returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = _TABLE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                // read 3 bytes
                let input := mload(dataPtr)

                // write 4 characters
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}

library Uint {
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal view returns (string memory) {
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
        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

/**
 * @title DotNugg V1 - onchain encoder/decoder for dotnugg files
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice yoU CAN'T HaVe ImAgES oN THe BlOCkcHAIn
 * @dev hold my margarita
 */
contract MockDotNugg is IDotNugg {
    function nuggify(
        bytes memory,
        bytes[] memory test,
        address,
        string memory name,
        string memory,
        uint256 tokenId,
        bytes32 seed,
        bytes memory
    ) public view override returns (string memory image) {
        console.log('len: ', test.length);
        image = Base64.encode(
            bytes(
                abi.encodePacked(
                    '{"name":"',
                    name,
                    Uint.toString(tokenId),
                    '","description":"',
                    Uint.toString(uint256(seed)),
                    '", "image": "',
                    'data:dotnugg;base64,ZG90bnVnZwAhAHEBTwAAAAAAAACZAOrhmUMeDP+oSx7l+bBC5fSfNeXrihLl2FUV//JuEP/ZLQ//+H0j///////xkyXl+lYe//hcD5n8yT7//HVp/5YPA//2dh7/+p1v/5Q3Cf/7GgaZYT8V/8lmGeUAAQAAAQAAAQIBAAEAAQIBAAEAAQEAAQMBAAQFBgUHBAAEBQYFBwQABAUGBQcEAAgFBgUHCQQACAoLBQwGDQwFCw4IAA8KEA4REgwTCxQVFAsOEAoWAAgOCwUMBgwFCw4IAAQLBQYFCwQABAUNBQYFBAAEBQYNBQQABAUGDQUEAAQFBgUEAAQFBgUEAAQFFwYEAAQFFwYMBhcGBAAEBQ0GFwYEAAQFDQYEAAQFDQYHBAAEGAUGDQcEAAQYBwUGBxgEAAQYBwUGBxgEAAQHBQYHGAQAAAQAAAAAAAAAAADW9t8kJdEWBxGPeE1LEDMi8AUkDwFiIPAXIQDQAAIwIAAMAAEAAwAAAAAqAAAkIAANADVADQEQZA0EYDDQVRINBHMNBKANBUUNBQAABQ4CECYOBAgeBBJA8AMAcPAAIzEPAQEzEPIBExHyv/////4=',
                    '"}'
                )
            ),
            'json'
        );
    }
}
