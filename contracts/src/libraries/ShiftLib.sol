pragma solidity 0.8.4;

library ShiftLib {
    function decodeSwapData(uint256 data)
        internal
        pure
        returns (
            address leader,
            uint48 epoch,
            uint16 amount,
            uint8 precision,
            bool tokenClaimed,
            bool exists,
            bool is1155
        )
    {
        assembly {
            is1155 := shr(248, data)
            exists := shr(248, shl(8, data))
            tokenClaimed := shr(248, shl(16, data))
            precision := shr(224, data)
            amount := shr(208, data)
            epoch := shr(160, data)
            leader := data
        }
    }

    function encodeSwapData(
        address leader,
        uint48 epoch,
        uint16 amount,
        uint8 precision,
        bool tokenClaimed,
        bool exists,
        bool is1155
    ) internal pure returns (uint256 res) {
        assembly {
            res := or(
                or(
                    or(
                        or(or(or(shl(248, is1155), shl(240, exists)), shl(232, tokenClaimed)), shl(224, precision)),
                        shl(208, amount)
                    ),
                    shl(160, epoch)
                ),
                leader
            )
        }
    }

    function encodeRoyaltyData(address receiver, uint16 bps) internal pure returns (uint256 res) {
        assembly {
            res := or(shl(160, bps), receiver)
        }
    }

    function decodeRoyaltyData(uint256 input) internal pure returns (address receiver, uint16 bps) {
        assembly {
            bps := shr(160, input)
            receiver := input
        }
    }

    function decodeOfferData(uint256 _unparsed) internal pure returns (uint128 amount, bool claimed) {
        assembly {
            claimed := shr(128, _unparsed)
            amount := _unparsed
        }
    }

    function encodeOfferData(uint128 amount, bool claimed) internal pure returns (uint256 res) {
        assembly {
            res := or(shl(128, claimed), amount)
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
