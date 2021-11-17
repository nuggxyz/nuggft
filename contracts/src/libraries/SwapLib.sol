pragma solidity 0.8.4;

import '../erc721/IERC721.sol';
import '../erc2981/IERC2981Receiver.sol';

import './Address.sol';
import '../interfaces/INuggSwapable.sol';
import '../interfaces/INuggMintable.sol';

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

    function takeToken(
        IERC721 nft,
        uint256 tokenid,
        address from
    ) internal {
        require(nft.supportsInterface(type(INuggSwapable).interfaceId), 'AUC:TT:0');

        // TODO check that royalty supports the

        require(nft.ownerOf(tokenid) == from, 'AUC:TT:1');

        nft.safeTransferFrom(from, address(this), tokenid);

        require(nft.ownerOf(tokenid) == address(this), 'AUC:TT:3');
    }

    function _giveToken(
        address nft,
        uint256 tokenid,
        address to
    ) internal {
        IERC721 _nft = IERC721(nft);
        require(_nft.ownerOf(tokenid) == address(this), 'AUC:TT:1');

        _nft.safeTransferFrom(address(this), to, tokenid);

        require(_nft.ownerOf(tokenid) == to, 'AUC:TT:3');
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

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param token token sending the royalties
     * @param tokenid uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC2981Received(
        address from,
        address to,
        address token,
        uint256 tokenid,
        address,
        uint256,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC2981Receiver(to).onERC2981Received(msg.sender, from, token, tokenid, address(0), 0, _data) returns (
                bytes4 retval
            ) {
                return retval == IERC2981Receiver.onERC2981Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert('ERC2981: transfer to non ERC2981Receiver implementer');
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
