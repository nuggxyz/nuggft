pragma solidity 0.8.4;

library ShiftLib {
    function decodeSwapData(uint256 _unparsed)
        internal
        pure
        returns (
            address leader,
            uint64 epoch,
            bool claimedByOwner,
            bool exists
        )
    {
        assembly {
            exists := shr(232, _unparsed)
            claimedByOwner := shr(248, shl(24, _unparsed))
            epoch := shr(160, _unparsed)
            leader := _unparsed
        }
    }

    function encodeSwapData(
        address leader,
        uint64 epoch,
        bool claimedByOwner,
        bool exists
    ) internal pure returns (uint256 res) {
        assembly {
            res := or(or(or(shl(232, exists), shl(224, claimedByOwner)), shl(160, epoch)), leader)
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
