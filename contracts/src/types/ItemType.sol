// 1/2 byte - size ---- 0-15
// 1/2 bytes - base -----  0-15
// 1/2 byte - traits 0-3
// 1/2 byte - traits 4-7 --- 2

// 1.5 bytes - head
// 1.5 bytes - eyes
// 1.5 bytes - mouth
// 1.5 bytes - other
// 1.5 bytes - other2 ---- 7.5  9.5

// 1.5 bytes - head
// 1.5 bytes - eyes
// 1.5 bytes - mouth
// 1.5 bytes - other
// 1.5 bytes - other2 ---- 7.5  17

// 1.5 bytes - head
// 1.5 bytes - eyes
// 1.5 bytes - mouth
// 1.5 bytes - other
// 1.5 bytes - other2 ---- 7.5  24.5

// 1.5 bytes - head
// 1.5 bytes - eyes
// 1.5 bytes - mouth
// 1.5 bytes - other
// 1.5 bytes - other2 ---- 7.5  32

// each nugg gets 10 items (2 of each item) (10 bytes)

// need to determine the order those pop up in

// first 10 under 128 - if not hit, load them up at the end

// need to figure out what determines the randomnness (last 10 bytes)

//

// each item has a rarity of 1/256, 2/256,

//

pragma solidity 0.8.10;

import 'hardhat/console.sol';
import '../libraries/ShiftLib2.sol';

library ItemType {
    using ShiftLib2 for uint256;

    uint8 constant HEAD_INDEX = 0;
    uint8 constant EYES_INDEX = 1;
    uint8 constant MOUTH_INDEX = 2;
    uint8 constant OTHER_INDEX = 3;
    uint8 constant SPECIAL_INDEX = 4;

    uint8 constant NUM_ATTRS = 5;
    uint8 constant NUM_SLOTS = 4;

    uint16 constant BLOCKED_ITEM = 0xffff;

    uint16 constant OPEN_ITEM = 0x0000;

    function size(uint256 input) internal pure returns (uint8 res) {
        res = input.bit4(0);
    }

    function base(uint256 input) internal pure returns (uint8 res) {
        res = input.bit4(4);
    }

    function checkSlot(uint8 slot) internal pure {
        require(slot < NUM_SLOTS, 'IT:S:0');
    }

    function checkIndex(uint8 index) internal pure {
        require(index < NUM_ATTRS, 'IT:A:0');
    }

    function valid(
        uint256 input,
        uint8 index,
        uint8 slot
    ) internal pure returns (bool res) {
        checkSlot(slot);
        checkIndex(index);

        // uint8 s = size(input);

        // uint8 check = (slot - 1) * NUM_ATTRS + index;

        if (slot == 0 || size(input) >= (slot - 1) * NUM_ATTRS + index) return true;

        // head    1 = 0
        // mouth   1 = 1
        // eyes    1 = 2
        // other   1 = 3
        // special 1 = 4
        // head    2 = 5
        // mouth   2 = 6
        // eyes    2 = 7
        // other   2 = 8
        // special 2 = 9
        // head    3 = 10
        // mouth   3 = 11
        // eyes    3 = 12
        // other   3 = 13
        // special 3 = 14
    }

    enum Index {
        HEAD,
        EYES,
        MOUTH,
        OTHER,
        SPECIAL
    }

    function item(
        uint256 input,
        Index index,
        uint8 slot
    ) internal pure returns (uint16 res) {
        if (valid(input, uint8(index), slot)) {
            res = input.bit12(16 + (48 * uint8(index)) + (12 * slot));
        } else {
            res = BLOCKED_ITEM;
        }
    }

    function item(
        uint256 input,
        Index index,
        uint8 slot,
        uint16 update
    ) internal pure returns (uint256 res) {
        res = input.bit12(16 + (48 * uint8(index)) + (12 * slot), update);
    }

    // function item(
    //     uint256 input,
    //     uint8 index,
    //     uint8 slot
    // ) internal pure returns (uint16 res) {
    //     if (valid(input, index, slot)) {
    //         res = input.bit12(16 + (48 * index) + (12 * slot));
    //     } else {
    //         res = BLOCKED_ITEM;
    //     }
    // }

    // function item(
    //     uint256 input,
    //     uint8 index,
    //     uint8 slot,
    //     uint16 update
    // ) internal pure returns (uint256 res) {
    //     res = input.bit12(16 + (48 * index) + (12 * slot), update);
    // }

    // function head(uint256 input, uint8 index) internal pure returns (uint16 res) {
    //     checkSlot(index);
    //     res = item(input, HEAD_INDEX, index);
    // }

    // function head(
    //     uint256 input,
    //     uint8 index,
    //     uint16 update
    // ) internal pure returns (uint256 res) {
    //     checkSlot(index);
    //     res = item(input, HEAD_INDEX, index, update);
    // }

    // function eyes(uint256 input, uint8 index) internal pure returns (uint16 res) {
    //     checkSlot(index);
    //     res = item(input, EYES_INDEX, index);
    // }

    // function eyes(
    //     uint256 input,
    //     uint8 index,
    //     uint16 update
    // ) internal pure returns (uint256 res) {
    //     checkSlot(index);
    //     res = item(input, EYES_INDEX, index, update);
    // }

    // function mouth(uint256 input, uint8 slot) internal pure returns (uint16 res) {
    //     checkSlot(slot);
    //     res = item(input, MOUTH_INDEX, slot);
    // }

    // function mouth(
    //     uint256 input,
    //     uint8 slot,
    //     uint16 update
    // ) internal pure returns (uint256 res) {
    //     checkSlot(slot);
    //     res = item(input, MOUTH_INDEX, slot, update);
    // }

    // function other(uint256 input, uint8 slot) internal pure returns (uint16 res) {
    //     checkSlot(slot);
    //     res = item(input, OTHER_INDEX, slot);
    // }

    // function other(
    //     uint256 input,
    //     uint8 slot,
    //     uint16 update
    // ) internal pure returns (uint256 res) {
    //     checkSlot(slot);
    //     res = item(input, OTHER_INDEX, slot, update);
    // }

    // function special(uint256 input, uint8 slot) internal pure returns (uint16 res) {
    //     checkSlot(slot);
    //     res = item(input, SPECIAL_INDEX, slot);
    // }

    // function special(
    //     uint256 input,
    //     uint8 slot,
    //     uint16 update
    // ) internal pure returns (uint256 res) {
    //     checkSlot(slot);
    //     res = item(input, SPECIAL_INDEX, slot, update);
    // }
}
