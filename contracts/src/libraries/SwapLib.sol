pragma solidity 0.8.4;

import '../erc721/IERC721.sol';

import './Address.sol';

library SwapLib {
    using Address for address;
    using Address for address payable;

    struct OfferData {
        bool claimed;
        address account;
        uint128 amount;
    }

    struct SwapData {
        address nft;
        uint256 tokenid;
        uint256 num;
        address leader;
        uint128 leaderAmount;
        uint64 epoch;
        address owner;
        bool claimedByOwner;
        uint64 activeEpoch;
        bool exists;
    }

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

    function checkOwner(address token, address asker) internal view returns (bool res) {
        (bool ok, bytes memory returnData) = token.staticcall(abi.encodeWithSignature('owner()'));
        if (!ok) return false;
        return abi.decode(returnData, (address)) == asker;
    }

    function encodeRoyaltyData(address receiver, uint16 bps) internal pure returns (uint256 res) {
        assembly {
            res := or(shl(160, bps), receiver)
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

    function decodeSwapId(uint256 _unparsed)
        internal
        pure
        returns (
            address nft,
            uint256 tokenid,
            uint256 swapNum
        )
    {
        assembly {
            swapNum := shr(224, _unparsed)
            tokenid := shr(160, _unparsed)
            nft := _unparsed
        }
    }

    function encodeSwapId(
        address nft,
        uint256 tokenid,
        uint256 swapNum
    ) internal pure returns (uint256 res) {
        assembly {
            res := or(or(shl(224, swapNum), shl(160, tokenid)), nft)
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

    function moveERC721(
        address nft,
        uint256 tokenid,
        address from,
        address to
    ) internal {
        require(IERC721(nft).ownerOf(tokenid) == from, 'AUC:TT:1');

        IERC721(nft).safeTransferFrom(from, to, tokenid);

        require(IERC721(nft).ownerOf(tokenid) == to, 'AUC:TT:3');
    }

    function validateOfferIncrement(SwapData memory swap, OfferData memory offer) internal pure returns (bool) {
        return offer.amount > swap.leaderAmount + ((swap.leaderAmount * 100) / 10000);
    }

    function hasVaildEpoch(SwapData memory swap) internal pure returns (bool) {
        return swap.epoch >= swap.activeEpoch && swap.epoch - swap.activeEpoch <= 1000;
    }

    function isOver(SwapData memory swap) internal pure returns (bool) {
        return swap.exists && (swap.activeEpoch > swap.epoch || swap.claimedByOwner);
    }

    function isActive(SwapData memory swap) internal pure returns (bool) {
        return swap.exists && !swap.claimedByOwner && swap.activeEpoch <= swap.epoch;
    }
}
