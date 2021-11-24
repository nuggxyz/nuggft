pragma solidity 0.8.4;

library ShiftLib {
    function unmaskZero(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := input
            if eq(res, not(0)) {
                res := 0
            }
        }
    }

    function maskZero(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := input
            if eq(res, 0) {
                res := not(0)
            }
        }
    }

    function getBool(uint256 input, uint8 at) internal pure returns (bool res) {
        assembly {
            res := and(shr(at, input), 0x1)
        }
    }

    function setBool(
        uint256 input,
        uint8 at,
        bool to
    ) internal pure returns (uint256 res) {
        assembly {
            res := input
            switch to
            case 1 {
                res := or(res, shl(at, 0x1))
            }
            default {
                res := or(res, shl(at, 0x0))
            }
        }
    }


    function maskit(uint8 bits) internal pure returns (uint256 res) {
        assembly {
            res := sub(shl(add(bits, 1), 0x1), 0x1)
        }
    }

    function getCint(
        uint256 input,
        uint8 at,
        uint8 bits,
        uint256 resl
    ) internal pure returns (uint256 res) {
        uint256 mask = maskit(bits);
        assembly {
            res := and(shr(at, input), mask)
            let i := and(res, 0xff)
            res := shl(mul(4, i), shr(8, res))
            res := mul(res, resl)
        }
    }

    // 6 bytes
    function setCint(
        uint256 base,
        uint8 at,
        uint8 bits,
        uint256 resl,
        uint256 to
    ) internal pure returns (uint256 base_out, uint256 rem) {
        uint256 mask = maskit(bits);
        assembly {
            let in := to
            to := div(to, resl)
            for {} gt(to, shr(8, mask)) {} {
                base_out := add(base_out, 0x01)
                to := shr(4, to)
            }
            to := or(shl(8, to), base_out)
            let out := shl(mul(4, base_out), shr(8, to))
            rem := sub(in, mul(out, resl))
            base := and(base, not(shl(at, mask)))
            base_out := or(base, shl(at, to))
        }
    }

    function getUint(
        uint256 input,
        uint8 at,
        uint8 bits
    ) internal pure returns (uint256 res) {
        uint256 mask = maskit(bits);
        assembly {
            res := and(shr(at, input), mask)
        }
    }

    // 5 bytes
    function setUint(
        uint256 input,
        uint8 at,
        uint8 bits,
        uint256 to
    ) internal pure returns (uint256 res) {
        uint256 mask = maskit(bits);
        assembly {
            res := and(input, not(shl(at, mask)))
            res := or(res, shl(at, to))
        }
    }



    function getAddress(uint256 input, uint8 at) internal pure returns (address res) {
        assembly {
            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            res := and(shr(at, input), mask)
        }
    }

    // 5 bytes
    function setAddress(
        uint256 input,
        uint8 at,
        address to
    ) internal pure returns (uint256 res) {
        assembly {
            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            input := and(input, not(shl(at, mask)))
            res := or(input, shl(at, to))
        }
    }
}

