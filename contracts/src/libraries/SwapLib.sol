pragma solidity 0.8.4;

import '../erc721/IERC721.sol';
import '../erc1155/IERC1155.sol';

import '../erc2981/IERC2981.sol';

import './ShiftLib.sol';
import './Address.sol';
import './QuadMath.sol';
import './CheapMath.sol';

library SwapLib {
    using Address for address;
    using Address for address payable;
    using CheapMath for uint16;

    // uint16 constant MAX_ROYALTY_BPS = 1000;
    // uint16 constant FULL_ROYALTY_BPS = 10000;

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
        uint128 eth;
    }

    struct SwapData {
        address token;
        uint256 tokenid;
        uint256 num;
        address leader;
        uint128 eth;
        uint48 epoch;
        uint48 activeEpoch;
        address owner;
        uint16 bps;
        bool tokenClaimed;
        bool royClaimed;
        bool is1155;
    }

    // function decodeSwapData(uint256 encodedSwapData) internal returns (SwapData memory res) {
    //     (res.leader, res.epoch, res.eth, res.precision, res.bps, res.tokenClaimed) = ShiftLib.decodeSwapData(
    //         encodedSwapData
    //     );

    //     res.exists = res.leader != address(0);
    //     res.is1155 = res.eth != 0;
    // }

    function checkOwner(address token, address asker) internal view returns (bool res) {
        (bool ok, bytes memory returnData) = token.staticcall(abi.encodeWithSignature('owner()'));
        if (!ok) return false;
        return abi.decode(returnData, (address)) == asker;
    }

    // most of these are LOSER, but want to make sure we catch any bugs in testing
    function checkClaimer(SwapData memory swap, OfferData memory offer) internal pure returns (ClaimerStatus) {
        if (offer.eth == 0) return ClaimerStatus.DID_NOT_OFFER;

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
    ) internal view returns (uint16 res) {
        (address receiver, uint256 bps) = ShiftLib.decodeRoyaltyData(encodedRoyaltyData);
        if (bps > 0) return uint16(bps);
        if (receiver == address(0)) {
            // for projects that indicate no royalties
            try IERC165(token).supportsInterface(type(IERC2981).interfaceId) returns (bool support) {
                if (support) {
                    try IERC2981(token).royaltyInfo(tokenid, 10000) returns (address, uint256 _bps) {
                        return uint16(_bps);
                    } catch {}
                }
            } catch {}
        } else {}
    }

    function takeBPS(uint256 total, uint256 bps) internal pure returns (uint256 res) {
        res = QuadMath.mulDiv(total, bps < 1000 ? bps : 1000, 10000);
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
        address from,
        address to
    ) internal {
        uint256 toStart = IERC1155(token).balanceOf(to, tokenid);

        require(IERC1155(token).balanceOf(from, tokenid) >= 1, 'AUC:TT:1');

        IERC1155(token).safeTransferFrom(from, to, tokenid, 1, '');

        require(IERC1155(token).balanceOf(to, tokenid) - toStart == 1, 'AUC:TT:3');
    }

    function validateOfferIncrement(SwapData memory swap, OfferData memory offer) internal pure returns (bool) {
        return offer.eth > swap.eth + ((swap.eth * 100) / 10000);
    }

    function hasVaildEpoch(SwapData memory swap) internal pure returns (bool) {
        return swap.epoch >= swap.activeEpoch && swap.epoch - swap.activeEpoch <= 1000;
    }

    function isOver(SwapData memory swap) internal pure returns (bool) {
        return swap.eth > 0 && (swap.activeEpoch > swap.epoch || swap.tokenClaimed);
    }

    function isActive(SwapData memory swap) internal pure returns (bool) {
        return swap.eth > 0 && !swap.tokenClaimed && swap.activeEpoch <= swap.epoch;
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
