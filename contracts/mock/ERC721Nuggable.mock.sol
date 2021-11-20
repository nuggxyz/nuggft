// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../src/erc721/ERC721Enumerable.sol';
import '../src/interfaces/INuggSwap.sol';
import '../src/interfaces/IERC721Nuggable.sol';

/**
 * @title Nugg Labs NFT Collection 0 - "NuggFT"
 * @author Nugg Labs - @danny7even & @dub6ix - 2021
 * @notice entrily onchain generative NFT
 * @dev this is art
 *
 * Note: epochs correlate directly to tokenIDs
 * Note: no images are stored in their final form - they are generated by view/pure functions at query time completly onchain
 * Note: the block hash corresponding to the start of an epoch is used as the "random" seed
 * Note: epochs are 256 blocks long as block hashes only exist for 256 blocks
 */
contract MockERC721Nuggable is IERC721Nuggable, ERC721Enumerable {
    INuggSwap public nuggswap;
    uint256 public epochOffset;
    address public owner;

    constructor(address royalty, address _nuggswap) ERC721('Mock ERC721 Nuggable', 'MockERC721Nuggable') {
        nuggswap = INuggSwap(_nuggswap);
        epochOffset = nuggswap.currentEpochId();
        owner = royalty;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable) returns (bool) {
        return interfaceId == type(IERC721Nuggable).interfaceId || super.supportsInterface(interfaceId);
    }

    // function royaltyInfo(uint256, uint256 value) external view override returns (address, uint256) {
    //     return (owner, (value * 1000) / 10000);
    // }

    function nsMint(uint256 currentEpochId) external override returns (uint256 tokenId) {
        tokenId = epochToTokenId(currentEpochId);
        require(!_exists(tokenId), 'NFT:NSM:0');
        _safeMint(address(nuggswap), tokenId);
    }

    function epochToTokenId(uint256 epoch) public view override returns (uint256 tokenId) {
        tokenId = epoch - epochOffset;
    }

    function currentTokenId() public view returns (uint256 tokenId) {
        tokenId = epochToTokenId(nuggswap.currentEpochId());
    }

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory res) {}
}