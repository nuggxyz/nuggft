pragma solidity 0.8.4;

import "hardhat/console.sol";
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

        // function fletcher16(address a) internal pure returns (uint16 res) {
        // uint16 sum1 = 0;
        // uint16 sum2 = 0;
        // for (uint256 index = 0; index < data.length; index++) {
        //     sum1 = (sum1 + uint8(data[index])) % 255;
        //     sum2 = (sum2 + sum1) % 255;
        // }
        // res = (sum2 << 8) | sum1;
        // }

    // function caddress(address a) internal pure returns (uint112 res) {
    //     assembly {
    //         let sum1 := 0
    //         let sum2 := 0
    //         let tmp := a
    //         for {
    //             let index := 0
    //         } lt(index, 20) {
    //             index := add(index, 0x2)
    //         } {
    //             sum1 := mod(add(sum1, and(0xffff, tmp)), 0xffff)
    //             sum2 := mod(add(sum1, sum2), 0xffff)
    //             tmp := shr(0xf, tmp)
    //         }
    //         res := or(and(shr(48, a), 0xFFFFFFFFFFFFFFFFFFFF00000000), or(shl(8, sum2), sum1))
    //     }
    // }




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



    function pushFirstEmpty(uint256 input, uint8 itemId) internal view returns (uint256 res, uint8 index) {
        uint256[] memory _items = items(input);
        for (uint8 i = 0; i < _items.length; i++) {
            if (_items[i] == 0) {
                index = i + 1;
                break;
            }
        }
        console.logBytes32(bytes32(input));

        require(index > 0, 'SL:PFM:0');

        index--;

        res = pushItem(input, itemId, index);

        console.logBytes32(bytes32(res));

    }

    function popFirstMatch(uint256 input, uint8 itemId)
        internal
        view
        returns (
            uint256 res,
            uint8 popped,
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
                console.logBytes32(bytes32(input));
                console.logBytes1(bytes1(itemId));

        require(index > 0, 'SL:PFM:0');

        index--;


        (res, popped) = popItem(input, index);

        console.logBytes32(bytes32(res));

        require(popped == itemId, 'SL:PFM:1');
    }

    function items(uint256 input) internal pure returns (uint256[] memory res) {
        uint256 s = size(input);
        res = new uint256[](s);
        input >>= 8;
        for (uint256 i = 0; i < s; i++) {
            input >>= 8;
            res[i] = input & 0xff;
        }
    }

    function itemsWithTokenId(uint256 input, uint256 tokenId) internal pure returns (uint256[] memory res) {
        uint256 s = size(input);
        res = new uint256[](s + 1);
        res[0] = tokenId;
        input >>= 8;
        for (uint256 i = 1; i < res.length; i++) {
            input >>= 8;
            res[i] = input & 0xff;
        }
    }

    function pushItem(
        uint256 input,
        uint8 item,
        uint8 at
    ) internal pure returns (uint256 res) {
        assembly {
            let offset := add(16, mul(8, at))
            res := and(input, not(shl(offset, 0xff)))
            res := or(input, shl(offset, item))
        }
    }

    function popItem(uint256 input, uint8 at) internal pure returns (uint256 res, uint8 item) {
        assembly {
            let offset := add(16, mul(8, at))
            res := and(input, not(shl(offset, 0xff)))
            item := shr(offset, input)
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
}
