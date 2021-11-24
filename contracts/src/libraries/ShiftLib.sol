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

    // function getCint48(uint256 input, uint8 at) internal pure returns (uint256 res) {
    //     assembly {
    //         res := and(shr(at, input), 0xFFFFFFFFFFFF)
    //         let i := and(res, 0xff)
    //         res := shl(mul(4, i), shr(8, res))
    //         res := mul(res, 0xE8D4A51000)
    //     }
    // }

    // 6 bytes
    // function setCint40(uint256 base, uint8 at, uint256 to) internal pure returns (uint256 base_out, uint256 rem) {
    //     assembly {
    //         let mask := 0xFFFFFFFFFFFF

    //         let in := to
    //         to := div(to, 0xE8D4A51000)

    //         for {} gt(to, shr(8, mask)) {} {
    //             base_out := add(base_out, 0x01)
    //             to := shr(4, to)
    //         }

    //         to := or(shl(8, to), base_out)

    //         let out := shl(mul(4, base_out), shr(8, to))
    //         rem := sub(in, mul(out, 0xE8D4A51000))

    //         base := and(base, not(shl(at, mask)))
    //         base_out := or(base, shl(at, to))

    //     }
    // }

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

    // function getUint40(uint256 input, uint8 at) internal pure returns (uint256 res) {

    //     assembly {
    //         let mask := 0xFFFFFFFFFF
    //         res := and(shr(at, input), mask)
    //     }
    // }

    // // 5 bytes
    // function setUint40(
    //     uint256 input,
    //     uint8 at,
    //     uint40 to
    // ) internal pure returns (uint256 res) {
    //     assembly {
    //         let mask := 0xFFFFFFFFFF
    //         res := and(input, not(shl(at, mask)))
    //         res := or(res, shl(at, to))
    //     }
    // }

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

// function formattedToken(uint256 e) internal view returns (uint256 res) {
//     assembly {
//         res := or(shl(96 , address()) , e)
//     }
// }

// function formattedTokenEpoch(uint256 input) internal pure returns (uint256 res) {
//     assembly {
//         res := and(input, 0xffffffffffff)
//     }
// }

// function formattedTokenAddress(uint256 input) internal pure returns (address res) {
//     assembly {
//         res := shr(96, input)
//     }

// }

// cannot unset, only set or notset

// function setRoyaltyClaimed(uint256 input) internal pure returns (uint256 res) {
//     assembly {

//         res := or(input, shl(254, 0x1))
//     }
// }

// function setFeeClaimed(uint256 input) internal pure returns (uint256 res) {
//     assembly {
//         res := or(input, shl(255, 0x1))
//     }
// }

// function hasRtmFlag(uint256 input) internal pure returns (bool res) {
//     assembly {
//     res := eq(shr(160, input), 0xffffffffffffffffffffffff)

//     }
// }

// function setRtmFlag(uint256 input) internal pure returns (uint256 res) {
//     assembly {
//     res := or(input, 0xffffffffffffffffffffffff0000000000000000000000000000000000000000)

//     }
// }

// 9 f's
// function setEpoch(uint256 input, uint256 update) internal pure returns (uint256 res) {
//     assert(update <= 0xFFFFFFFFF);
//     assembly {
//         //                0xfffffffffffffffddffffffffffffffccfffffffffffffffffffffffffffffff)
//         res := and(input, 0xf000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffff)
//         res := or(res, shl(216, update))
//     }
// }

// function addr(uint256 input) internal pure returns (address res) {
//     assembly {
//         res := input
//     }
// }

// function offerIsOwner(uint256 input) internal pure returns (bool res) {
//     res = isFeeClaimed(input);

// }

// function swapEndedByOwner(uint256 input) internal pure returns (bool res) {
//     res = isTokenClaimed(input);
// }

// function formattedToken(uint256 e) internal view returns (uint256 res) {
//     assembly {
//         res := or(shl(96 , address()) , e)
//     }
// }

// function formattedTokenEpoch(uint256 input) internal pure returns (uint256 res) {
//     assembly {
//         res := and(input, 0xffffffffffff)
//     }
// }

// function formattedTokenAddress(uint256 input) internal pure returns (address res) {
//     assembly {
//         res := shr(96, input)
//     }

// }

// // cannot unset, only set or notset
// function setIs1155(uint256 input, bool to) internal pure returns (uint256 res) {
//     assembly {
//         res := input
//         if to {
//              res := or(res, shl(252, 0x1))
//         }
//     }
// }

// function setTokenClaimed(uint256 input) internal pure returns (uint256 res) {
//     assembly {
//         res := or(input, shl(253, 0x1))
//     }
// }

// function setRoyaltyClaimed(uint256 input) internal pure returns (uint256 res) {
//     assembly {

//         res := or(input, shl(254, 0x1))
//     }
// }

// function setFeeClaimed(uint256 input) internal pure returns (uint256 res) {
//     assembly {
//         res := or(input, shl(255, 0x1))
//     }
// }

// function setOfferIsOwner(uint256 input) internal pure returns (uint256 res) {
//     res = setFeeClaimed(input);
// }

// function hasRtmFlag(uint256 input) internal pure returns (bool res) {
//     assembly {
//     res := eq(shr(160, input), 0xffffffffffffffffffffffff)

//     }
// }

// function setRtmFlag(uint256 input) internal pure returns (uint256 res) {
//     assembly {
//     res := or(input, 0xffffffffffffffffffffffff0000000000000000000000000000000000000000)

//     }
// }
