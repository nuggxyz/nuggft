import '../erc721/IERC721.sol';
import '../erc2981/IERC2981Receiver.sol';

import './Address.sol';
import '../interfaces/INuggSwapable.sol';
import '../interfaces/INuggMintable.sol';

library SwapLib {
    using Address for address;
    using Address for address payable;

    struct BidData {
        bool claimed;
        address account;
        uint128 amount;
    }

    struct AuctionData {
        IERC721 nft;
        uint128 tokenId;
        uint128 num;
        uint256 id;
        address leader;
        uint128 leaderAmount;
        uint64 epoch;
        address owner;
        bool claimedByOwner;
        uint64 activeEpoch;
        bool exists;
    }

    function decodeAuctionData(uint256 _unparsed)
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
            let tmp := _unparsed

            exists := shr(232, tmp)
            claimedByOwner := shr(248, shl(24, tmp))
            epoch := shr(160, tmp)
            leader := tmp
        }
    }

    function encodeAuctionData(
        address leader,
        uint64 epoch,
        bool claimedByOwner,
        bool exists
    ) internal pure returns (uint256 res) {
        assembly {
            res := or(or(or(shl(232, exists), shl(224, claimedByOwner)), shl(160, epoch)), leader)
        }
    }

    function decodeAuctionId(uint256 _unparsed)
        internal
        pure
        returns (
            address nft,
            uint64 tokenId,
            uint32 auctionNum
        )
    {
        assembly {
            let tmp := _unparsed
            auctionNum := shr(224, tmp)
            tokenId := shr(160, tmp)
            nft := tmp
        }
    }

    function encodeAuctionId(
        address nft,
        uint64 tokenId,
        uint32 auctionNum
    ) internal pure returns (uint256 res) {
        assembly {
            res := or(or(shl(224, auctionNum), shl(160, tokenId)), nft)
        }
    }

    function decodeBidData(uint256 _unparsed) internal pure returns (uint128 amount, bool claimed) {
        assembly {
            let tmp := _unparsed
            claimed := shr(128, tmp)
            amount := tmp
        }
    }

    function encodeBidData(uint128 amount, bool claimed) internal pure returns (uint256 res) {
        assembly {
            res := or(shl(128, claimed), amount)
        }
    }

    function takeToken(
        IERC721 nft,
        uint128 tokenId,
        address from
    ) internal {
        require(nft.supportsInterface(type(INuggSwapable).interfaceId), 'AUC:TT:0');

        // TODO check that royalty supports the

        require(nft.ownerOf(tokenId) == from, 'AUC:TT:1');

        nft.safeTransferFrom(from, address(this), tokenId);

        require(nft.ownerOf(tokenId) == address(this), 'AUC:TT:3');
    }

    function mintToken(AuctionData memory auction) internal {
        require(auction.nft.supportsInterface(type(INuggMintable).interfaceId), 'AUC:MT:0');

        INuggMintable _nft = INuggMintable(address(auction.nft));

        require(auction.activeEpoch == auction.tokenId, 'AUC:MT:1');

        try auction.nft.ownerOf(auction.tokenId) returns (address) {
            require(false, 'SLIB:MT:2');
        } catch (bytes memory) {}

        _nft.mint();

        require((auction.nft.ownerOf(auction.tokenId) == address(this)), 'AUC:MT:3');

        handleInitAuction(auction, BidData({account: address(0), amount: 0, claimed: false}), auction.activeEpoch, 0);
    }

    function _giveToken(
        IERC721 nft,
        uint128 tokenId,
        address to
    ) internal {
        require(nft.ownerOf(tokenId) == address(this), 'AUC:TT:1');

        nft.safeTransferFrom(address(this), to, tokenId);

        require(nft.ownerOf(tokenId) == to, 'AUC:TT:3');
    }

    function handleBidPlaced(
        AuctionData memory auction,
        BidData memory bid,
        uint256 amount
    ) internal {
        bid.amount += uint128(amount);

        require(isActive(auction), 'SL:OBP:0');
        require(validateBidIncrement(auction, bid), 'SL:OBP:1');

        auction.leader = bid.account;

        (address royAccount, uint256 roy) = IERC2981(address(auction.nft)).royaltyInfo(auction.tokenId, amount);

        IERC2981Receiver(royAccount).onERC2981Received{value: roy}(
            address(this),
            bid.account,
            address(auction.nft),
            auction.tokenId,
            address(0),
            roy,
            ''
        );
    }

    function handleBidClaim(AuctionData memory auction, BidData memory bid) internal {
        require(auction.exists, 'SL:HBC:0');
        require(!bid.claimed, 'AUC:CLM:0');
        require(bid.amount > 0, 'AUC:CLM:1');

        bid.claimed = true;

        if (isOver(auction)) {
            if (bid.account == auction.leader) {
                _giveToken(auction.nft, auction.tokenId, bid.account);
            } else {
                payable(bid.account).sendValue(bid.amount);
            }
        } else {
            require(bid.account == auction.leader && bid.account == auction.owner, 'AUC:CLM:2');
            auction.claimedByOwner;
        }
    }

    function handleInitAuction(
        AuctionData memory auction,
        BidData memory bid,
        uint64 epoch,
        uint128 floor
    ) internal pure {
        require(!auction.exists, 'AUC:IA:0');

        auction.epoch = epoch;
        require(hasVaildEpoch(auction), 'AUC:IA:1');

        auction.leader = bid.account;
        auction.exists = true;

        bid.amount = floor;
    }

    function validateBidIncrement(AuctionData memory auction, BidData memory bid) internal pure returns (bool) {
        return bid.amount > auction.leaderAmount + ((auction.leaderAmount * 100) / 10000);
    }

    function hasVaildEpoch(AuctionData memory auction) internal pure returns (bool) {
        return auction.epoch >= auction.activeEpoch && auction.epoch - auction.activeEpoch <= 1000;
    }

    function isOver(AuctionData memory auction) internal pure returns (bool) {
        return auction.exists && (auction.activeEpoch > auction.epoch || auction.claimedByOwner);
    }

    function isActive(AuctionData memory auction) internal pure returns (bool) {
        return auction.exists && !auction.claimedByOwner && auction.activeEpoch <= auction.epoch;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param token token sending the royalties
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC2981Received(
        address from,
        address to,
        address token,
        uint256 tokenId,
        address erc20,
        uint256 amount,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC2981Receiver(to).onERC2981Received(msg.sender, from, token, tokenId, address(0), 0, _data) returns (
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
