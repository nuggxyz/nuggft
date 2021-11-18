// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../src/erc721/ERC721Enumerable.sol';
import '../src/erc2981/IERC2981.sol';

contract MockERC721Royalties is IERC2981, ERC721Enumerable {
    address public owner;

    constructor(address royalty) ERC721('Mock ERC721 Royalties', 'Mock_ERC721Royalties') {
        owner = royalty;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256, uint256 value) external view override returns (address, uint256) {
        return (owner, (value * 1000) / 10000);
    }

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory res) {}
}
