library MockShiftLib {
    function mock_decodeSwapData(uint256 _unparsed)
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

    function mock_encodeSwapData(
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

    function mock_decodeSwapId(uint256 _unparsed)
        internal
        pure
        returns (
            address nft,
            uint64 tokenId,
            uint32 swapNum
        )
    {
        swapNum = uint32(_unparsed >> (256 - 32));
        tokenId = uint64(_unparsed >> (256 - 96));
        nft = address(uint160(_unparsed));
    }

    function mock_encodeSwapId(
        address nft,
        uint64 tokenId,
        uint32 swapId
    ) internal pure returns (uint256 res) {
        res = (uint256(swapId) << (256 - 32)) | (uint256(tokenId) << (256 - 96)) | uint160(address(nft));
    }

    function mock_decodeOfferData(uint256 _unparsed) internal pure returns (uint128 amount, bool claimed) {
        claimed = bool((_unparsed >> 128) == 1);
        amount = uint128(_unparsed);
    }

    function mock_encodeOfferData(uint128 amount, bool claimed) internal pure returns (uint256 res) {
        res = (uint256(claimed ? 1 : 0) << 128) | amount;
    }
}
