pragma solidity 0.8.4;

import '../erc721/IERC721.sol';
import '../erc1155/IERC1155.sol';

import '../erc2981/IERC2981.sol';

import './ShiftLib.sol';
import './Address.sol';

library SwapLib {
    using Address for address;
    using Address for address payable;

    uint16 constant MAX_ROYALTY_BPS = 1000;
    uint16 constant FULL_ROYALTY_BPS = 10000;

    enum ClaimerStatus {
        OWNER_PAPERHAND,
        OWNER_DIAMONDHAND,
        OWNER_DIAMONDHAND_EARLY,
        OWNER_NO_OFFERS,
        WINNER,
        LOSER,
        PREMADONA,
        DID_NOT_OFFER,
        HAS_ALREADY_CLAIMED,
        WISE_GUY
    }

    struct OfferData {
        bool claimed;
        address account;
        uint128 amount;
    }

    struct SwapData {
        address token;
        bool is1155;
        uint256 tokenid;
        uint256 num;
        uint16 amount;
        uint8 precision;
        address leader;
        uint128 leaderAmount;
        uint48 epoch;
        address owner;
        bool tokenClaimed;
        uint48 activeEpoch;
        bool exists;
    }

    function checkOwner(address token, address asker) internal view returns (bool res) {
        (bool ok, bytes memory returnData) = token.staticcall(abi.encodeWithSignature('owner()'));
        if (!ok) return false;
        return abi.decode(returnData, (address)) == asker;
    }

    // most of these are LOSER, but want to make sure we catch any bugs in testing
    function checkClaimer(SwapData memory swap, OfferData memory offer) internal pure returns (ClaimerStatus) {
        if (offer.amount == 0) return ClaimerStatus.DID_NOT_OFFER;

        if (offer.claimed) return ClaimerStatus.HAS_ALREADY_CLAIMED;

        if (isOver(swap)) {
            if (swap.owner == offer.account) {
                if (swap.owner == swap.leader) {
                    return ClaimerStatus.OWNER_NO_OFFERS;
                } else {
                    return ClaimerStatus.OWNER_DIAMONDHAND;
                }
            } else if (swap.leader == offer.account) {
                return ClaimerStatus.WINNER;
            } else {
                return ClaimerStatus.LOSER;
            }
        } else {
            if (swap.owner == offer.account) {
                if (swap.owner == swap.leader) {
                    return ClaimerStatus.OWNER_PAPERHAND;
                } else {
                    return ClaimerStatus.OWNER_DIAMONDHAND_EARLY;
                }
            } else {
                if (swap.owner == swap.leader) {
                    return ClaimerStatus.WISE_GUY;
                } else {
                    return ClaimerStatus.PREMADONA;
                }
            }
        }
    }

    function checkRoyalties(
        address token,
        uint256 tokenid,
        uint256 encodedRoyaltyData
    )
        internal
        view
        returns (
            bool found,
            address receiver,
            uint256 bps
        )
    {
        (receiver, bps) = ShiftLib.decodeRoyaltyData(encodedRoyaltyData);

        if (receiver == address(0)) {
            try IERC165(token).supportsInterface(type(IERC2981).interfaceId) returns (bool res) {
                if (res) {
                    try IERC2981(token).royaltyInfo(tokenid, FULL_ROYALTY_BPS) returns (
                        address _receiver,
                        uint256 _bps
                    ) {
                        receiver = _receiver;
                        bps = _bps;
                        found = true;
                    } catch {}
                }
            } catch {}
        } else {
            found = true;
        }
    }

    function takeBPS(uint256 total, uint256 bps) internal pure returns (uint256 res) {
        res = (total * (bps < MAX_ROYALTY_BPS ? bps : MAX_ROYALTY_BPS)) / FULL_ROYALTY_BPS;
    }

    function moveERC721(
        address token,
        uint256 tokenid,
        address from,
        address to
    ) internal {
        require(IERC721(token).ownerOf(tokenid) == from, 'AUC:TT:1');

        IERC721(token).safeTransferFrom(from, to, tokenid);

        require(IERC721(token).ownerOf(tokenid) == to, 'AUC:TT:3');
    }

    function moveERC1155(
        address token,
        uint256 tokenid,
        uint256 amount,
        address from,
        address to
    ) internal {
        uint256 toStart = IERC1155(token).balanceOf(to, tokenid);

        require(IERC1155(token).balanceOf(from, tokenid) >= amount, 'AUC:TT:1');

        IERC1155(token).safeTransferFrom(from, to, tokenid, amount, '');

        require(IERC1155(token).balanceOf(to, tokenid) - toStart == amount, 'AUC:TT:3');
    }

    function validateOfferIncrement(SwapData memory swap, OfferData memory offer) internal pure returns (bool) {
        return offer.amount > swap.leaderAmount + ((swap.leaderAmount * 100) / 10000);
    }

    function hasVaildEpoch(SwapData memory swap) internal pure returns (bool) {
        return swap.epoch >= swap.activeEpoch && swap.epoch - swap.activeEpoch <= 1000;
    }

    function isOver(SwapData memory swap) internal pure returns (bool) {
        return swap.exists && (swap.activeEpoch > swap.epoch || swap.tokenClaimed);
    }

    function isActive(SwapData memory swap) internal pure returns (bool) {
        return swap.exists && !swap.tokenClaimed && swap.activeEpoch <= swap.epoch;
    }
}

// if (swap.owner == offer.account) {
//     if (offer.account == swap.leader) {}

//     if (isOver(swap)) {
//         if (offer.account == swap.leader) {
//             return ClaimerStatus.WINNER;
//         } else {
//             return ClaimerStatus.LOSER;
//         }
//     } else {
//         require(offer.account == swap.leader && offer.account == swap.owner, 'AUC:CLM:2');
//         swap.tokenClaimed = true;
//     }
// }
