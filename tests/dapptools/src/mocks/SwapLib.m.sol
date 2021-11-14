import '../../../../contracts/erc721/IERC721.sol';

library MockSwapLib {
    function mock_decodeAuctionData(uint256 _unparsed)
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

    function mock_encodeAuctionData(
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

    function mock_decodeAuctionId(uint256 _unparsed)
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

    function mock_encodeAuctionId(
        IERC721 nft,
        uint64 tokenId,
        uint32 auctionId
    ) internal pure returns (uint256 res) {
        res = (uint256(auctionId) << (256 - 32)) | (uint256(tokenId) << (256 - 64)) | uint160(address(nft));
    }

    function mock_encodeAuctionListId(IERC721 nft, uint64 tokenId) internal pure returns (uint256 res) {
        res = (uint256(tokenId) << (160)) | uint160(address(nft));
    }

    function mock_decodeAuctionListId(uint256 _unparsed) internal pure returns (IERC721 nft, uint64 tokenId) {
        tokenId = uint64(_unparsed >> 160);
        nft = IERC721(address(uint160(_unparsed)));
    }

    function mock_decodeBid(uint256 _unparsed) internal pure returns (uint128 amount, bool claimed) {
        amount = uint128(_unparsed >> 128);
        claimed = bool(uint128(_unparsed) == 1);
    }

    function mock_encodeBidData(uint248 amount, bool claimed) internal pure returns (uint256 res) {
        res = (uint256(amount) << 248) | (claimed ? 1 : 0);
    }
}
