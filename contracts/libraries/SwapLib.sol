import '../erc721/IERC721.sol';
import './Address.sol';
import '../interfaces/INuggSwapable.sol';
import '../interfaces/INuggMintable.sol';

library SwapLib {
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
            claimedByOwner := shr(224, tmp)
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

        require(nft.ownerOf(tokenId) == from, 'AUC:TT:1');

        nft.safeTransferFrom(from, address(this), tokenId);

        require(nft.ownerOf(tokenId) == address(this), 'AUC:TT:3');
    }

    function mintToken(AuctionData memory auction) internal {
        require(auction.nft.supportsInterface(type(INuggMintable).interfaceId), 'AUC:TT:0');

        INuggMintable _nft = INuggMintable(address(auction.nft));

        require(auction.activeEpoch == auction.tokenId, 'AUC:MT:1');

        require(auction.nft.ownerOf(auction.tokenId) == address(0), 'AUC:MT:2');

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

        nft.safeTransferFrom(to, address(this), tokenId);

        require(nft.ownerOf(tokenId) == to, 'AUC:TT:3');
    }

    function handleBidPlaced(
        AuctionData memory auction,
        BidData memory bid,
        uint256 amount
    ) internal pure {
        bid.amount += uint128(amount);

        require(isActive(auction), 'SL:OBP:0');
        require(validateBidIncrement(auction, bid), 'SL:OBP:1');

        auction.leader = bid.account;
    }

    function handleBidClaim(AuctionData memory auction, BidData memory bid) internal {
        require(!bid.claimed && bid.amount > 0, 'AUC:CLM:1');

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

        bid.amount = floor;
    }

    function validateBidIncrement(AuctionData memory auction, BidData memory bid) internal pure returns (bool) {
        return bid.amount > auction.leaderAmount + ((auction.leaderAmount * 1000) / 100000);
    }

    function hasVaildEpoch(AuctionData memory auction) internal pure returns (bool) {
        return auction.epoch > auction.activeEpoch && auction.epoch - auction.activeEpoch <= 1000;
    }

    function isOver(AuctionData memory auction) internal pure returns (bool) {
        return auction.exists && (auction.activeEpoch <= auction.epoch || auction.claimedByOwner);
    }

    function isActive(AuctionData memory auction) internal pure returns (bool) {
        return auction.exists && !auction.claimedByOwner && auction.activeEpoch < auction.epoch;
    }
}
