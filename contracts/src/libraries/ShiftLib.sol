pragma solidity 0.8.4;

library ShiftLib {
    function isOwner(uint256 input) internal pure returns (bool res) {
        assembly {
            res := and(shr(128, input), 0xff)
        }
    }

    function isClaimed(uint256 input) internal pure returns (bool res) {
        assembly {
            res := and(shr(136, input), 0xff)
        }
    }

    function is1155(uint256 input) internal pure returns (bool res) {
        assembly {
            res := and(shr(208, input), 0xff)
        }
    }

    function isTokenClaimed(uint256 input) internal pure returns (bool res) {
        assembly {
            res := and(shr(216, input), 0xff)
        }
    }

    function isRoyaltyClaimed(uint256 input) internal pure returns (bool res) {
        assembly {
            res := and(shr(224, input), 0xff)
        }
    }

    function isFeeClaimed(uint256 input) internal pure returns (bool res) {
        assembly {
            res := and(shr(232, input), 0xff)
        }
    }

    function isActive(uint256 input, uint256 activeEpoch) internal pure returns (bool res) {
        assembly {
            input := and(shr(160, input), 0x7FFFFFFF)

            res := or(lt(input, activeEpoch), eq(input, activeEpoch))

            input := and(shr(48, input), 0xFF)

            res := or(res, input)
        }
    }

    // function isValidIncrement(uint256 input, uint256 amount) pure internal returns (bool res) {
    //     assembly {
    //         input := and(shr(160, input), 0x7FFFFFFF)
    //         res := or(lt(input, activeEpoch), eq(input, activeEpoch))
    //     }
    // }

    function eth(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := and(input, 0xffffffffffffffffffffffffffffffff)
        }
    }

    function epoch(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := and(shr(160, input), 0xFFFFFFFFFFFF)
        }
    }

    function setAccount(uint256 input, address update) internal pure returns (uint256 res) {
        assembly {
            // res := or(shl(160, shr(160, input)), update)
            //                  0xfffffffffffffffddffffffffffffffccfffffffffffffffffffffffffffffff)
            input := and(input, 0xffffffffffffffffffffffff0000000000000000000000000000000000000000)
            res := or(input, update)
        }
    }

    function setEpoch(uint256 input, uint256 update) internal pure returns (uint256 res) {
        assert(update <= type(uint48).max);
        assembly {
            //                0xfffffffffffffffddffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffff)
            res := or(res, shl(160, update))
        }
    }

    function setIs1155(uint256 input) internal pure returns (uint256 res) {
        // assert(update <= type(uint48).max);
        assembly {
            //                0xfffffffffffffffffffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xffffffffff00ffffffffffffffffffffffffffffffffffffffffffffffffffff)
            res := or(res, shl(208, 0x01))
            // res := and(input, shl(208, 0x01))
        }
    }

    function setTokenClaimed(uint256 input) internal pure returns (uint256 res) {
        // assert(update <= type(uint48).max);
        assembly {
            //                0xfffffffffffffffffffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xffffffff00ffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            res := or(res, shl(216, 0x1))
        }
    }

    function setRoyaltyClaimed(uint256 input) internal pure returns (uint256 res) {
        // assert(update <= type(uint48).max);
        assembly {
            //                0xfffffffffffffffffffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xffffff00ffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            res := or(res, shl(224, 0x1))
        }
    }

    function setFeeClaimed(uint256 input) internal pure returns (uint256 res) {
        // assert(update <= type(uint48).max);
        assembly {
            //                0xfffffffffffffffffffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xffff00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            res := or(res, shl(232, 0x1))
        }
    }

    function setClaimed(uint256 input) internal pure returns (uint256 res) {
        // assert(update <= type(uint48).max);
        assembly {
            //                0xfffffffffffffffffffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffffffff)
            res := or(res, shl(136, 0x1))
        }
    }

    function setOwner(uint256 input) internal pure returns (uint256 res) {
        // assert(update <= type(uint48).max);
        assembly {
            //                0xfffffffffffffffffffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xffffffffffffffffffffffffffffff00ffffffffffffffffffffffffffffffff)
            res := or(res, shl(128, 0x1))
        }
    }

    function setEth(uint256 input, uint256 val) internal pure returns (uint256 res) {
        assert(val <= type(uint128).max);
        assembly {
            // if eq(input, 0) {
            //     return(0x0, val)
            // }
            //                0xfffffffffffffffffffffffffffffffccfffffffffffffffffffffffffffffff)
            res := and(input, 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000)
            res := or(res, val)
        }
    }

    function setOffer(uint128 amount, bool owner) internal pure returns (uint256 res) {
        assembly {
            res := or(shl(128, shl(8, owner)), amount)
        }
    }
}

// function decodeSwapId(uint256 _unparsed)
//     internal
//     pure
//     returns (
//         address nft,
//         uint256 tokenid,
//         uint256 swapNum
//     )
// {
//     assembly {
//         swapNum := shr(224, _unparsed)
//         tokenid := shr(160, _unparsed)
//         nft := _unparsed
//     }
// }

// function encodeSwapId(
//     address nft,
//     uint256 tokenid,
//     uint256 swapNum
// ) internal pure returns (uint256 res) {
//     assembly {
//         res := or(or(shl(224, swapNum), shl(160, tokenid)), nft)
//     }
// }

// function decodeSwapData(uint256 data)
//     internal
//     pure
//     returns (
//         address leader,
//         uint48 epoch,
//         uint16 bps,
//         bool is1155,
//         bool tokenClaimed,
//         bool royClaimed
//     )
// // bool mint
// {
//     // leader = data;

//     assembly {
//         leader := data
//         data := shr(160, data)

//         epoch := data
//         data := shr(48, data)

//         bps := data
//         data := shr(16, data)

//         is1155 := shl(248, data)
//         data := shr(8, data)

//         tokenClaimed := shl(248, data)
//         data := shr(8, data)

//         royClaimed := data
//     }
// }

// function encodeSwapData(
//     address leader,
//     uint256 epoch,
//     // uint256 bps,
//     bool is1155,
//     bool tokenClaimed,
//     bool royClaimed
// )
//     internal
//     pure
//     returns (
//         // bool mint
//         uint256 res
//     )
// {
//     assert(epoch <= type(uint48).max);

//     assembly {
//         res := feeClaimed

//         res := or(shl(8, res), royaltyClaimed)

//         res := or(shl(8, res), tokenClaimed)

//         res := or(shl(8, res), is1155)

//         // res := or(shl(16, res), bps)

//         res := or(shl(48, res), epoch)

//         res := or(shl(160, res), leader)
//     }
// }

// function encodeRoyaltyData(address receiver, uint16 bps) internal pure returns (uint256 res) {
//     assembly {
//         res := or(shl(160, bps), receiver)
//     }
// }

// function decodeRoyaltyData(uint256 input) internal pure returns (address receiver, uint16 bps) {
//     assembly {
//         bps := shr(160, input)
//         receiver := input
//     }
// }

// function decodeOfferData(uint256 _unparsed) internal pure returns (uint128 amount, bool claimed) {
//     assembly {
//         claimed := shr(128, _unparsed)
//         amount := _unparsed
//     }
// }

// function encodeOfferData(uint128 amount, bool claimed) internal pure returns (uint256 res) {
//     assembly {
//         res := or(shl(128, claimed), amount)
//     }
// }

// function decodeOfferData2(uint256 _unparsed) internal pure returns (uint128 amount, bool claimed) {
//     assembly {
//         claimed := shr(128, _unparsed)
//         amount := _unparsed
//     }
// }

// function setOffer(
//     uint128 amount,
//     bool claimed,
//     bool owner
// ) internal pure returns (uint256 res) {
//     assembly {
//         res := or(shl(128, shl(8, owner)), amount)
//     }
// }
