// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../src/erc721/ERC721Enumerable.sol';
import './Ownable.mock.sol';

contract MockERC721Ownable is ERC721Enumerable, Ownable {
    constructor() ERC721('Mock ERC721', 'MockERC721') {}

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory res) {}
}
