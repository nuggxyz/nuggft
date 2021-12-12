// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;


library ShiftLib {
    function unmask(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := input
            if eq(res, not(0)) {
                res := 0
            }
        }
    }

    function mask(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := input
            if eq(res, 0) {
                res := not(0)
            }
        }
    }

    function account(uint256 input) internal pure returns (uint160 res) {
        assembly {
            res := input
        }
    }

    function account(uint256 input, uint160 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffff0000000000000000000000000000000000000000)
            res := or(input, update)
        }
    }

    function isOwner(uint256 input, bool) internal pure returns (uint256 res) {
        assembly {
            res := or(input, shl(255, 0x1))
        }
    }

    function isOwner(uint256 input) internal pure returns (bool res) {
        assembly {
            res := and(shr(255, input), 0x1)
        }
    }

    function eth(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := and(shr(160, input), 0xFFFFFFFFFFFFFF)
            let i := and(res, 0xff)
            res := shl(mul(4, i), shr(8, res))
            res := mul(res, 0xE8D4A51000)
        }
    }

    // 14 f's
    function eth(uint256 input, uint256 update) internal pure returns (uint256 res, uint256 rem) {
        assembly {
            let in := update
            update := div(update, 0xE8D4A51000)
            for {
            } gt(update, 0xFFFFFFFFFFFF) {
                // 13
            } {
                res := add(res, 0x01)
                update := shr(4, update)
            }
            update := or(shl(8, update), res)
            let out := shl(mul(4, res), shr(8, update))
            rem := sub(in, mul(out, 0xE8D4A51000))
            input := and(input, 0xffffffffff00000000000000ffffffffffffffffffffffffffffffffffffffff)
            res := or(input, shl(160, update))
        }
    }

    // 9 f's
    function epoch(uint256 input, uint256 update) internal pure returns (uint256 res) {
        assert(update <= 0xFFFFFFFFF);
        assembly {
            //                0xfffffffffffffffddffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xf000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            res := or(res, shl(216, update))
        }
    }

    function epoch(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := and(shr(216, input), 0xFFFFFFFFF)
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

    function items(uint256 input) internal pure returns (uint256[] memory res) {
        uint256 s = size(input);
        res = new uint256[](s);
        input >>= 16;
        for (uint256 i = 0; i < s; i++) {
            res[i] = input & 0xffff;
            input >>= 16;
        }
    }

    // function itemsWithTokenId(uint256 input, uint256 tokenId) internal pure returns (uint256[] memory res) {
    //     uint256 s = size(input);
    //     res = new uint256[](s + 1);
    //     res[0] = tokenId;
    //     input >>= 8;
    //     for (uint256 i = 0; i < s; i++) {
    //         input >>= i == 0 ? 8 : 16;
    //         res[i] = input & 0xffff;
    //     }
    // }

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

    function base(uint256 input) internal pure returns (uint8 res) {
        assembly {
            res := and(shr(0x8, input), 0xff)
        }
    }

    function base(uint256 input, uint8 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00ff)
            res := or(shl(0x8, update), input)
        }
    }

    function item0(uint256 input, uint16 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000)
            res := or(shl(mul(16, 0), update), input)
        }
    }

    function item0(uint256 input) internal pure returns (uint16 res) {
        assembly {
            res := shr(mul(16, 0), input)
        }
    }

    function item1(uint256 input, uint16 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffff)
            res := or(shl(mul(16, 1), update), input)
        }
    }

    function item1(uint256 input) internal pure returns (uint16 res) {
        assembly {
            res := shr(mul(16, 1), input)
        }
    }

    function item2(uint256 input, uint16 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffff)
            res := or(shl(mul(16, 2), update), input)
        }
    }

    function item2(uint256 input) internal pure returns (uint16 res) {
        assembly {
            res := shr(mul(16, 2), input)
        }
    }

    function item3(uint256 input, uint16 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffff)
            res := or(shl(mul(16, 3), update), input)
        }
    }

    function item3(uint256 input) internal pure returns (uint16 res) {
        assembly {
            res := shr(mul(16, 3), input)
        }
    }

    function item4(uint256 input, uint16 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffff)
            res := or(shl(mul(16, 4), update), input)
        }
    }

    function item4(uint256 input) internal pure returns (uint16 res) {
        assembly {
            res := shr(mul(16, 4), input)
        }
    }

    function item(uint256 input, uint8 id) internal pure returns (uint16 res) {
        assembly {
            res := shr(mul(16, id), input)
        }
    }

    function item(uint256 input, uint16 update, uint8 id) internal pure returns (uint256 res) {
        assembly {
            input := and(input,not(shl(mul(16, id), 0xffff)))
            res := or(shl(mul(16, id), update), input)
        }
    }
}
