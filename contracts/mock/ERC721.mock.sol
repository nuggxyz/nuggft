// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../src/erc721/ERC721Enumerable.sol';

contract MocKERC721 is ERC721Enumerable {
    constructor() ERC721('Mock ERC721', 'MockERC721') {}

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory res) {}
}
