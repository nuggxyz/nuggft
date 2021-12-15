// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import {Print} from '../_test/utils/Print.sol';

library ShiftLib {
    function mask(uint256 bits) internal pure returns (uint256 res) {
        validateBits(bits);

        assembly {
            res := sub(exp(2, bits), 1)
        }
    }

    function fullsubmask(uint256 bits, uint256 pos) internal pure returns (uint256 res) {
        validatePos(pos);
        res = mask(bits);

        assembly {
            res := not(shl(res, pos))

            // res = ~(mask(bits) << offset);
        }
    }

    function set(
        uint256 preStore,
        uint256 bits,
        uint256 pos,
        uint256 value
    ) internal view returns (uint256 postStore) {
        validateNum(value, bits);

        postStore = preStore & fullsubmask(bits, pos);
        postStore |= (value << pos);
    }

    function get(
        uint256 store,
        uint256 bits,
        uint256 pos
    ) internal pure returns (uint256 value) {
        validatePos(pos);

        value = (store >> pos) & mask(bits);
    }

    /*///////////////////////////////////////////////////////////////
                                COMPRESSED
    //////////////////////////////////////////////////////////////*/

    function getCompressed(
        uint256 store,
        uint256 bits,
        uint256 pos
    ) internal pure returns (uint256 res) {
        validatePosWithLength(pos, bits - 8);

        res = get(store, bits, pos);

        uint256 i = res & 0xff;
        res >>= 8;
        res <<= (i * 4);
        res *= 0xE8D4A51000;

        // assembly {
        //     // res := and(shr(pos, store), 0xFFFFFFFFFFFFFF)
        //     let i := and(res, 0xff)
        //     res := shl(mul(4, i), shr(8, res))
        //     res := mul(res, 0xE8D4A51000)
        // }
    }

    // 14 f's
    function setCompressed(
        uint256 store,
        uint256 bits,
        uint256 pos,
        uint256 value
    ) internal view returns (uint256 res, uint256 dust) {
        require(bits > 8, 'SHIFT:SCE');

        validatePosWithLength(pos, bits);

        assembly {
            let ins := value
            value := div(value, 0xE8D4A51000)
            for {

            } gt(value, 0xFFFFFFFFFFFF) {

            } {
                res := add(res, 0x01)
                value := shr(4, value)
            }
            value := or(shl(8, value), res)
            let out := shl(mul(4, res), shr(8, value))
            dust := sub(ins, mul(out, 0xE8D4A51000))
        }
        validateNum(value >> 8, bits - 8);

        res = set(store, bits, pos, value);
    }

    /*///////////////////////////////////////////////////////////////
                                ARRAYS
    //////////////////////////////////////////////////////////////*/

    function getArray(
        uint256 store,
        uint256 bitsPerItem,
        uint256 pos,
        uint256 numItems
    ) internal pure returns (uint256[] memory arr) {
        validatePosWithLength(pos, numItems * bitsPerItem - 1);

        store = get(store, numItems * bitsPerItem, pos);

        arr = new uint256[](numItems);
        uint256 msk = mask(bitsPerItem);
        for (uint256 i = 0; i < numItems; i++) {
            arr[i] = store & msk;
            store >>= bitsPerItem;
        }
    }

    function setArray(
        uint256 store,
        uint256[] memory arr,
        uint256 bitsPerItem,
        uint256 pos
    ) internal view returns (uint256 res) {
        validatePosWithLength(pos, arr.length * bitsPerItem);

        for (uint256 i = arr.length; i > 0; i--) {
            validateNum(arr[i - 1], bitsPerItem);
            res |= arr[i - 1] << ((bitsPerItem * (i - 1)));
        }

        res = set(store, arr.length * bitsPerItem, pos, res);
    }

    /*///////////////////////////////////////////////////////////////
                            DYNAMIC ARRAY
    //////////////////////////////////////////////////////////////*/

    function setDynamicArray(
        uint256 store,
        uint256[] memory arr,
        uint256 bitsPerItem,
        uint256 pos,
        uint256 truelen,
        uint256 maxLen
    ) internal view returns (uint256 res) {
        validatePosWithLength(pos, maxLen * bitsPerItem + 16);

        // must be different than popDynamicArray
        require(truelen <= maxLen, 'SL:SDA:0');

        res = set(store, 16, pos, (maxLen << 8) | truelen);

        res = setArray(res, arr, bitsPerItem, pos + 16);
    }

    function getDynamicArray(
        uint256 store,
        uint256 bitsPerItem,
        uint256 pos
    )
        internal
        pure
        returns (
            uint256[] memory arr,
            uint256 len,
            uint256 maxlen
        )
    {
        len = get(store, 16, pos);

        maxlen = len >> 8;
        len &= 0xff;

        validatePosWithLength(pos, len * bitsPerItem + 16);

        arr = getArray(store, bitsPerItem, pos + 16, len);
    }

    function popDynamicArray(
        uint256 store,
        uint256 bitsPerItem,
        uint256 pos,
        uint256 id
    ) internal view returns (uint256 res) {
        (uint256[] memory arr, uint256 truelen, uint256 maxlen) = getDynamicArray(store, bitsPerItem, pos);

        require(truelen > 0, 'SL:PDA:0');

        bool found;
        for (uint8 i = 0; i < arr.length; i++) {
            if (arr[i] == id) found = true;

            if (found && i != arr.length) arr[i] = arr[i] + 1;
        }

        require(found, 'SL:PDA:0');

        res = setDynamicArray(store, arr, bitsPerItem, pos, truelen - 1, maxlen);
    }

    function pushDynamicArray(
        uint256 store,
        uint256 bitsPerItem,
        uint256 pos,
        uint256 id
    ) internal view returns (uint256 res) {
        (uint256[] memory arr, uint256 truelen, uint256 maxlen) = getDynamicArray(store, bitsPerItem, pos);

        require(truelen < maxlen, 'SL:PDA:0');

        arr[truelen] = id;

        res = setDynamicArray(store, arr, bitsPerItem, pos, truelen + 1, maxlen);
    }

    /*///////////////////////////////////////////////////////////////
                            COMMON BASE UNITS
    //////////////////////////////////////////////////////////////*/

    function validateNum(uint256 num, uint256 bits) internal view {
        // Event.log(num, "num", bits, "bits", mask(bits), "mask(bits)");
        require(num <= mask(bits), 'SHIFT:V:0');
    }

    function validateBits(uint256 bits) internal pure {
        require(bits <= 256 && bits > 0, 'SHIFT:BITS:0');
    }

    function validatePosWithLength(uint256 pos, uint256 length) internal pure {
        validateBits(length);
        require(pos < 256 - length && pos >= 0, 'SHIFT:POSWL:0');
    }

    function validatePos(uint256 pos) internal pure {
        require(pos < 256 && pos >= 0, 'SHIFT:POS:0');
    }
}
