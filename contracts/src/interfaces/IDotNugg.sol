interface IDotNugg {
    function nuggify(
        bytes memory _collection,
        bytes[] memory _items,
        address _resolver,
        string memory name,
        string memory description,
        uint256 tokenId,
        bytes32 seed,
        bytes memory data
    ) external view returns (string memory image);
}
