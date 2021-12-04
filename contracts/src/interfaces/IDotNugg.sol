// SPDX-License-Identifier: MIT

interface IDotNugg {
    function nuggify(
        uint256[] memory _collection,
        uint256[][] memory _items,
        address _resolver,
        bytes32 name,
        bytes32 description,
        uint256 tokenId,
        bytes memory data
    ) external view returns (string memory image);
}
