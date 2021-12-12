// SPDX-License-Identifier: MIT

import '../vault/LengthType.sol';

library ProofType {
    using LengthType for uint256;

    uint256 constant ID_SIZE = 16;
    uint256 constant ID_FEATURE_SIZE = 4;
    uint256 constant ID_NUMBER_SIZE = 12;

    function initFromSeed(uint256 lengthData, uint256 seed) internal pure returns (uint256 res) {
        require(seed != 0, 'seed');

        uint256 pick0 = ((seed >> (4 + ID_SIZE * 0)) & ShiftLib.mask(ID_NUMBER_SIZE)) % lengthData.length(0);
        uint256 pick1 = ((seed >> (4 + ID_SIZE * 1)) & ShiftLib.mask(ID_NUMBER_SIZE)) % lengthData.length(1);
        uint256 pick2 = ((seed >> (4 + ID_SIZE * 2)) & ShiftLib.mask(ID_NUMBER_SIZE)) % lengthData.length(2);

        uint256 pick3 = (seed >> 69) % 256;

        uint256 num = (seed >> (4 + ID_SIZE * 3)) & ShiftLib.mask(ID_NUMBER_SIZE);

        if (pick3 < 96) {
            pick3 = (3 << ID_NUMBER_SIZE) | (num % (lengthData.length(3)));
        } else if (pick3 < 192) {
            pick3 = (4 << ID_NUMBER_SIZE) | (num % (lengthData.length(4)));
        } else if (pick3 < 250) {
            pick3 = (5 << ID_NUMBER_SIZE) | (num % (lengthData.length(5)));
        } else {
            pick3 = (6 << ID_NUMBER_SIZE) | (num % (lengthData.length(6)));
        }
        pick1 |= 1 << ID_NUMBER_SIZE;
        pick2 |= 2 << ID_NUMBER_SIZE;

        res = (pick3 << (3 * ID_SIZE + 4)) | (pick2 << (2 * ID_SIZE + 4)) | (pick1 << (1 * ID_SIZE + 4)) | (pick0 << 4) | 3;
    }

    function size(uint256 input, uint8 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00)
            res := or(update, input)
        }
    }

    function size(uint256 input) internal pure returns (uint8 res) {
        assembly {
            res := and(input, 0xff)
        }
    }

    function items(uint256 input) internal pure returns (uint256[] memory res) {
        uint256 s = size(input);
        res = new uint256[](s);
        input >>= 4;
        for (uint256 i = 0; i < s; i++) {
            res[i] = input & 0xff;
            input >>= 8;
        }
    }

    function pushItem(
        uint256 input,
        uint16 itm,
        uint8 at
    ) internal pure returns (uint256 res) {
        assembly {
            let offset := add(16, mul(16, at))
            res := and(input, not(shl(offset, 0xffff)))
            res := or(input, shl(offset, itm))
        }
    }

    function popItem(uint256 input, uint8 at) internal pure returns (uint256 res, uint16 itm) {
        assembly {
            let offset := add(16, mul(16, at))
            res := and(input, not(shl(offset, 0xffff)))
            itm := shr(offset, input)
        }
    }

    function pushFirstEmpty(uint256 input, uint16 itemId) internal pure returns (uint256 res, uint8 index) {
        uint256[] memory _items = items(input);
        for (uint8 i = 0; i < _items.length; i++) {
            if (_items[i] == 0) {
                index = i + 1;
                break;
            }
        }

        require(index > 0, 'SL:PFM:A');

        index--;

        res = pushItem(input, itemId, index);
    }

    function popFirstMatch(uint256 input, uint16 itemId)
        internal
        pure
        returns (
            uint256 res,
            uint16 popped,
            uint8 index
        )
    {
        uint256[] memory _items = items(input);
        for (uint8 i = 0; i < _items.length; i++) {
            if (_items[i] == itemId) {
                index = i + 1;
                break;
            }
        }

        require(index > 0, 'SL:PFM:0');

        index--;

        (res, popped) = popItem(input, index);

        require(popped == itemId, 'SL:PFM:1');
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
