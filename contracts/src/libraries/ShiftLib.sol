pragma solidity 0.8.4;

library ShiftLib {
    function decodeSwapData(uint256 data)
        internal
        pure
        returns (
            address leader,
            uint48 epoch,
            uint16 bps,
            bool is1155,
            bool tokenClaimed,
            bool royClaimed
        )
    // bool mint
    {
        // leader = data;

        assembly {
            leader := data
            data := shr(160, data)

            epoch := data
            data := shr(48, data)

            bps := data
            data := shr(16, data)

            is1155 := shl(248, data)
            data := shr(8, data)

            tokenClaimed := shl(248, data)
            data := shr(8, data)

            royClaimed := data
        }
    }

    function encodeSwapData(
        address leader,
        uint48 epoch,
        uint16 bps,
        bool is1155,
        bool tokenClaimed,
        bool royClaimed
    )
        internal
        pure
        returns (
            // bool mint
            uint256 res
        )
    {
        assembly {
            res := royClaimed

            res := or(shl(8, res), tokenClaimed)

            res := or(shl(8, res), is1155)

            res := or(shl(16, res), bps)

            res := or(shl(48, res), epoch)

            res := or(shl(160, res), leader)
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
