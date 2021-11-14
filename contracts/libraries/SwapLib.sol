import '../erc721/IERC721.sol';
import './Address.sol';
import '../interfaces/INuggSwapable.sol';
import '../interfaces/INuggMintable.sol';

library SwapLib {
    using Address for address payable;

    struct BidData {
        bool claimed;
        address account;
        uint248 amount;
    }

    struct AuctionData {
        IERC721 nft;
        uint128 tokenId;
        uint128 num;
        uint256 id;
        address leader;
        uint248 leaderAmount;
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
        leader = address(uint160(_unparsed));
        epoch = uint64(_unparsed >> 160);
        claimedByOwner = bool(uint8(_unparsed >> (160 + 64)) == 1);
        exists = bool(uint8(_unparsed >> (160 + 64 + 8)) == 1);
    }

    function encodeAuctionData(
        address leader,
        uint64 epoch,
        bool claimedByOwner,
        bool exists
    ) internal pure returns (uint256 res) {
        res =
            (uint256(exists ? 1 : 0) << (160 + 64 + 8)) |
            (uint256(claimedByOwner ? 1 : 0) << (160 + 64)) |
            (uint256(epoch) << 160) |
            uint160(leader);
    }

    function decodeAuctionId(uint256 _unparsed)
        internal
        pure
        returns (
            IERC721 nft,
            uint128 tokenId,
            uint128 auctionId
        )
    {
        auctionId = uint32(_unparsed >> (256 - 32));
        tokenId = uint64(_unparsed >> (256 - 64));
        nft = IERC721(address(uint160(_unparsed)));
    }

    function encodeAuctionId(
        IERC721 nft,
        uint64 tokenId,
        uint32 auctionId
    ) internal pure returns (uint256 res) {
        res = (uint256(auctionId) << (256 - 32)) | (uint256(tokenId) << (256 - 64)) | uint160(address(nft));
    }

    function encodeAuctionListId(IERC721 nft, uint64 tokenId) internal pure returns (uint256 res) {
        res = (uint256(tokenId) << (160)) | uint160(address(nft));
    }

    function decodeAuctionListId(uint256 _unparsed) internal pure returns (IERC721 nft, uint64 tokenId) {
        tokenId = uint64(_unparsed >> 160);
        nft = IERC721(address(uint160(_unparsed)));
    }

    function decodeBid(uint256 _unparsed) internal pure returns (uint128 amount, bool claimed) {
        amount = uint128(_unparsed >> 128);
        claimed = bool(uint128(_unparsed) == 1);
    }

    function encodeBidData(uint248 amount, bool claimed) internal pure returns (uint256 res) {
        res = (uint256(amount) << 248) | (claimed ? 1 : 0);
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
        bid.amount += uint248(amount);

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
        uint248 floor
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
