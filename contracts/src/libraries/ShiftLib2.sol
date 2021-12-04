// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import 'hardhat/console.sol';

library ShiftLib2 {
    function bit1(uint256 input, uint8 pos) internal pure returns (bool res) {
        assembly {
            res := and(shr(pos, input), 0x3)
        }
    }

    function bit4(uint256 input, uint8 pos) internal pure returns (uint8 res) {
        assembly {
            res := and(shr(pos, input), 0xf)
        }
    }

    function bit8(uint256 input, uint8 pos) internal pure returns (uint8 res) {
        assembly {
            res := and(shr(pos, input), 0xff)
        }
    }

    function bit12(uint256 input, uint8 pos) internal pure returns (uint16 res) {
        assembly {
            res := and(shr(pos, input), 0xfff)
        }
    }

    function bit16(uint256 input, uint8 pos) internal pure returns (uint16 res) {
        assembly {
            res := and(shr(pos, input), 0xffff)
        }
    }

    function bit1(
        uint256 input,
        uint8 pos,
        bool update
    ) internal pure returns (uint256 res) {
        uint8 tu = update ? 0x1 : 0x0;
        assembly {
            input := and(not(shl(pos, 0x3)), input)
            res := or(input, shl(pos, tu))
        }
    }

    function bit4(
        uint256 input,
        uint8 pos,
        uint8 update
    ) internal pure returns (uint256 res) {
        require(update <= 0xf, 'SL:B4:0');
        assembly {
            input := and(not(shl(pos, 0xf)), input)
            res := or(input, shl(pos, update))
        }
    }

    function bit8(
        uint256 input,
        uint8 pos,
        uint8 update
    ) internal pure returns (uint256 res) {
        assembly {
            input := and(not(shl(pos, 0xff)), input)
            res := or(input, shl(pos, update))
        }
    }

    function bit12(
        uint256 input,
        uint8 pos,
        uint16 update
    ) internal pure returns (uint256 res) {
        require(update <= 0xfff, 'SL:B12:0');

        assembly {
            input := and(not(shl(pos, 0xfff)), input)
            res := or(input, shl(pos, update))
        }
    }

    function bit16(
        uint256 input,
        uint8 pos,
        uint16 update
    ) internal pure returns (uint256 res) {
        assembly {
            input := and(not(shl(pos, 0xffff)), input)
            res := or(input, shl(pos, update))
        }
    }
}
