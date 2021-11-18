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

    function checkOwner(address token, address asker) internal view returns (bool res) {
        (bool ok, bytes memory returnData) = token.staticcall(abi.encodeWithSignature('owner()'));
        if (!ok) return false;
        return abi.decode(returnData, (address)) == asker;
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
