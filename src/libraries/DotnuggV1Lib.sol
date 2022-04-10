// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

// import '../_test/utils/forge.sol';

library DotnuggV1Lib {
    uint8 constant DOTNUGG_HEADER_BYTE_LEN = 25;

    uint8 constant DOTNUGG_RUNTIME_BYTE_LEN = 1;

    bytes18 internal constant PROXY_INIT_CODE = 0x69_36_3d_3d_36_3d_3d_37_f0_33_FF_3d_52_60_0a_60_16_f3;

    bytes32 internal constant PROXY_INIT_CODE_HASH = keccak256(abi.encodePacked(PROXY_INIT_CODE));

    function size(address pointer) internal view returns (uint8 res) {
        assembly {
            // [======================================================================
            // the amount of items inside a dotnugg file are stored at byte #1 (0 based index)
            // here we copy that single byte from the file and store it in byte #31 of memory
            // this way, we can mload(0x00) to get the properly alignede integer from memory

            extcodecopy(pointer, 31, DOTNUGG_RUNTIME_BYTE_LEN, 0x01)

            // memory:                                           length of file  =  XX
            // [0x00] 0x////////////////////////////////////////////////////////////XX

            res := and(mload(0x00), 0xff)

            // // // we clear the scratch space we dirtied
            // mstore(0x00, 0x00)
            // // // memory layout:
            // // // [0x00] 0x00000000000000000000000000000000000000000000000000000000000000
            // // // =======================================================================]
        }
    }

    function search(
        address safe,
        uint8 feature,
        uint256 seed
    ) internal view returns (uint8 res) {
        address loc = location(safe, feature);

        uint256 high = size(loc);

        // prettier-ignore
        /// @solidity memory-safe-assembly
        assembly {

            // we adjust the seed to be unique per feature and safe, yet still deterministic

            mstore(0x00, seed)
            mstore(0x20, or(shl(160, feature), safe))

            seed := keccak256( //-----------------------------------------
                0x00, /* [ seed                                  ]    0x20
                0x20     [ uint8(feature) | address(safe)        ] */ 0x40
            ) // ---------------------------------------------------------

            // normalize seed to be <= type(uint16).max
            // if we did not want to use weights, we could just mod by "len" and have our final value
            // without any calcualtion
            seed := mod(seed, 0xffff)

            //////////////////////////////////////////////////////////////////////////

            // Get a pointer to some free memory.
            // no need update pointer becasue after this function, the loaded data is no longer needed
            //    and solidity does not assume the free memory pointer points to "clean" data
            let A := mload(0x40)

            // Copy the code into memory right after the 32 bytes we used to store the len.
            extcodecopy(loc, add(0x20, A), add(DOTNUGG_RUNTIME_BYTE_LEN, 1), mul(high, 2))

            // adjust data pointer to make mload return our uint16[] index easily using below funciton
            A := add(A, 0x2)

            function index(arr, m) -> val {
                val := and(mload(add(arr, shl(1, m))), 0xffff)
            }

            //////////////////////////////////////////////////////////////////////////

            // each dotnuggv1 file includes a sorted weight list that we can use to convert "random" seeds into item numbers:

            // lets say we have an file containing 4 itmes with these as their respective weights:
            // [ 0.10  0.10  0.15  0.15 ]

            // then on chain, an array like this is stored: (represented in decimal for the example)
            // [ 2000  4000  7000  10000 ]

            // assuming we can only pass a seed between 0 and 10000, we know that:
            // - we have an 20% chance, of picking a number less than weight 1      -  0    < x < 2000
            // - we have an 20% chance, of picking a number between weights 1 and 2 -  2000 < x < 4000
            // - we have an 30% chance, of picking a number between weights 2 and 3 -  4000 < x < 7000
            // - we have an 30% chance, of picking a number between weights 3 and 4 -  7000 < x < 10000

            // now, all we need to do is pick a seed, say "6942", and search for which number it is between

            // the higher of which will be the value we are looking for

            // in our example, "6942" is between weights 2 and 3, so [res = 3]

            //////////////////////////////////////////////////////////////////////////

            // right most "successor" binary search
            // https://en.wikipedia.org/wiki/Binary_search_algorithm#Procedure_for_finding_the_rightmost_element

            let L := 0
            let R := high

            for { } lt(L, R) { } {
                let m := shr(1, add(L, R)) // == (L + R) / 2
                switch gt(index(A, m), seed)
                case 1  { R := m         }
                default { L := add(m, 1) }
            }

            // we add one because items are 1 base indexed, not 0
            res := add(R, 1)
        }
    }

    function location(address safe, uint8 feature) internal pure returns (address res) {
        bytes32 h = PROXY_INIT_CODE_HASH;

        /// @solidity memory-safe-assembly
        assembly {
            let mptr := mload(0x40)

            // [0x00] 0x00000000000000000000000000000000000000000000000000000000000000
            // [0x20] 0x00000000000000000000000000000000000000000000000000000000000000
            // [0x40] 0x________________________FREE_MEMORY_PTR_______________________

            //////////////////////////////////////////////////////////////////////////

            mstore8(0x00, 0xff)
            mstore(0x01, shl(96, safe))
            mstore(0x15, feature)
            mstore(0x35, h)

            // [0x00] 0xff>_________________safe__________________>___________________
            // [0x20] 0x________________feature___________________>___________________
            // [0x40] 0x________________PROXY_INIT_CODE_HASH______////////////////////

            //////////////////////////////////////////////////////////////////////////

            mstore(0x02, shl(96, keccak256(0x00, 0x55)))
            mstore8(0x00, 0xD6)
            mstore8(0x01, 0x94)
            mstore8(0x16, 0x01)

            // [0x00] 0xD694_________ADDRESS_OF_FILE_CREATOR________01////////////////
            // [0x20] ////////////////////////////////////////////////////////////////
            // [0x40] ////////////////////////////////////////////////////////////////

            //////////////////////////////////////////////////////////////////////////

            res := shr(96, shl(96, keccak256(0x00, 0x17)))

            //////////////////////////////////////////////////////////////////////////

            mstore(0x00, 0x00)
            mstore(0x20, 0x00)
            mstore(0x40, mptr)

            // [0x00] 0x00000000000000000000000000000000000000000000000000000000000000
            // [0x20] 0x00000000000000000000000000000000000000000000000000000000000000
            // [0x40] 0x________________________FREE_MEMORY_PTR_______________________
        }
    }

    function readBytecodeAsArray(
        address file,
        uint256 start,
        uint256 len
    ) private view returns (uint256[] memory data) {
        // prettier-ignore
        assembly {
            let offset := sub(0x20, mod(len, 0x20))

            let arrlen := add(0x01, div(len, 0x20))

            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to size and running the result through the logic above ensures
            // the memory pointer remains word-aligned, following the Solidity convention.
            mstore(0x40, add(data, and(add(add(add(len, 32), offset), 31), not(31))))

            // Store the len of the data in the first 32 byte chunk of free memory.
            mstore(data, arrlen)

            // Copy the code into memory right after the 32 bytes we used to store the len.
            extcodecopy(file, add(add(data, 32), offset), start, len)
        }
    }

    function readBytecode(
        address file,
        uint256 start,
        uint256 len
    ) private view returns (bytes memory data) {
        // prettier-ignore
        assembly {
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to len and running the result through the logic above ensures
            // the memory pointer remains word-aligned, following the Solidity convention.
            mstore(0x40, add(data, and(add(add(len, 32), 31), not(31))))

            // Store the len of the data in the first 32 byte chunk of free memory.
            mstore(data, len)

            // Copy the code into memory right after the 32 bytes we used to store the len.
            extcodecopy(file, add(data, 32), start, len)
        }
    }

    function rarity(
        address safe,
        uint8 feature,
        uint8 position
    ) internal view returns (uint16 res) {
        address loc = location(safe, uint8(feature));

        assembly {
            switch eq(position, 1)
            case 1 {
                extcodecopy(loc, 30, add(DOTNUGG_RUNTIME_BYTE_LEN, 1), 2)

                res := and(mload(0x00), 0xffff)
            }
            default {
                extcodecopy(loc, 28, add(add(DOTNUGG_RUNTIME_BYTE_LEN, 1), mul(sub(position, 2), 2)), 4)

                res := and(mload(0x00), 0xffffffff)

                let low := shr(16, res)

                res := sub(and(res, 0xffff), low)
            }
        }
    }
}

function decodeProof(uint256 input) pure returns (uint16[16] memory res) {
    unchecked {
        for (uint256 i = 0; i < 16; i++) {
            res[i] = uint16(input);
            input >>= 16;
        }
    }
}

function decodeProofCore(uint256 proof) pure returns (uint8[8] memory res) {
    unchecked {
        for (uint256 i = 0; i < 8; i++) {
            (uint8 feature, uint8 pos) = parseItemId(uint16(proof));
            if (res[feature] == 0) res[feature] = pos;
            proof >>= 16;
        }
    }
}

function encodeProof(uint8[8] memory ids) pure returns (uint256 proof) {
    unchecked {
        for (uint256 i = 0; i < 8; i++) proof |= ((i << 8) | uint256(ids[i])) << (i << 3);
    }
}

function encodeProof(uint16[16] memory ids) pure returns (uint256 proof) {
    unchecked {
        for (uint256 i = 0; i < 16; i++) proof |= uint256(ids[i]) << (i << 4);
    }
}

/// @notice parses the external itemId into a feautre and position
/// @dev this follows dotnugg v1 specification
/// @param itemId -> the external itemId
/// @return feat -> the feautre of the item
/// @return pos -> the file storage position of the item
function parseItemId(uint16 itemId) pure returns (uint8 feat, uint8 pos) {
    feat = uint8(itemId >> 8);
    pos = uint8(itemId);
}

/**
 * @dev Converts a `uint256` to its ASCII `string` decimal representation.
 */
function toAsciiBytes(uint256 value) pure returns (bytes memory buffer) {
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

function parseItemIdAsString(uint16 itemId, string[8] memory labels) pure returns (string memory) {
    return string.concat(labels[(itemId >> 8)], " ", string(toAsciiBytes((itemId) & 0xff)));
}

// /**
//  * @dev Converts a `uint256` to its ASCII `string` decimal representation.
//  */
// function toAsciiBytes(uint256 value) internal pure returns (bytes memory buffer) {
//     // Inspired by OraclizeAPI's implementation - MIT licence
//     // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

//     if (value == 0) {
//         return "0";
//     }
//     uint64 alpha = 0xfedca9876543210;
//      "0123456789abcdef"[val % base]
// bytes1(uint8(48 + uint256(value % 10)));
//     assembly {
//         mstore(0x0, 0x0)
// for {
//     let i := 0
//         } and(iszero(iszero(value)), iszero(iszero(i))) {
//             i := sub(i, 1)
//             value := div(value, 10)
//         } {
//             mstore(mod)
//         }

//     }

//     assembly {
//         let temp := value
//         let dig := 0
//         for {

//         } iszero(iszero(temp)) {

//         } {
//             dig := add(dig, 1)
//             temp := div(temp, 10)
//         }
//     }
//     uint256 temp = value;
//     uint256 digits;
//     while (temp != 0) {
//         digits++;
//         temp /= 10;
//     }

//     buffer = new bytes(digits);

//     while (value != 0) {
//         digits -= 1;
//         buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
//         value /= 10;
//     }
//     return buffer;
// }
