// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './interfaces/IDotNuggFileResolver.sol';
import './interfaces/IDotNuggColorResolver.sol';

import './interfaces/IDotNugg.sol';
import './interfaces/INuggFT.sol';
import './NuggSwap.sol';
import './interfaces/IxNUGG.sol';

import './erc721/ERC721.sol';
import './erc2981/IERC2981.sol';
import '../tests/mock/MockDotNuggImplementer.sol';

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
contract NuggFT is INuggFT, ERC721, MockDotNuggImplementer {
    IDotNugg internal dotnugg;
    IxNUGG internal xnugg;
    NuggSwap internal nuggswap;
    IDotNuggFileResolver internal nuggin;

    uint256 public epochOffset;

    constructor(
        address _xnugg,
        address _nuggswap,
        address _dotnugg,
        address _nuggin
    ) ERC721('Nugg Fungable Token', 'NuggFT') {
        dotnugg = IDotNugg(_dotnugg);
        nuggswap = NuggSwap(_nuggswap);
        xnugg = IxNUGG(_xnugg);
        nuggin = IDotNuggFileResolver(_nuggin);

        // require(nuggin.supportsInterface(type(IDotNuggFileResolver).interfaceId), 'NUG:LAUNCH:0');

        epochOffset = nuggswap.currentEpochId();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        return
            interfaceId == type(INuggMintable).interfaceId ||
            interfaceId == type(INuggSwapable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256, uint256 value) external view override returns (address, uint256) {
        return (address(xnugg), (value * 1000) / 10000);
    }

    function nuggSwapMint(uint256 currentEpochId) external override returns (uint256 tokenId) {
        tokenId = epochToTokenId(currentEpochId);
        require(!_exists(tokenId), 'NFT:NSM:0');
        _safeMint(address(nuggswap), tokenId);
    }

    function epochToTokenId(uint256 epoch) public view returns (uint256 tokenId) {
        tokenId = epoch - epochOffset;
    }

    function currentTokenId() public view returns (uint256 tokenId) {
        tokenId = epochToTokenId(nuggswap.currentEpochId());
    }

    function _beforeTokenTransfer(
        address,
        address,
        uint256
    ) internal view override {
        require(msg_sender() == address(nuggswap), 'NFT:BTT:0');
    }

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory res) {
        require(_exists(tokenId) || tokenId == currentTokenId(), 'NFT:NSM:0');
        res = _generateTokenURI(tokenId, address(nuggin));
    }

    function tokenURI(uint256 tokenId, address resolver) public view returns (string memory res) {
        require(_exists(tokenId) || tokenId == currentTokenId(), 'NFT:NSM:0');
        res = _generateTokenURI(tokenId, resolver);
    }

    /**
     * @notice calcualtes the token uri for a given epoch
     */
    function _generateTokenURI(uint256 tokenId, address resolver) internal view returns (string memory) {
        bytes32 seed = nuggswap.getSeedWithOffset(tokenId, epochOffset);

        string memory uriName = 'NuggFT {#}';
        string memory uriDesc = 'the description';

        return dotnugg.nuggify(collection_, _getItems(seed), resolver, uriName, uriDesc, tokenId, seed, '');
    }

    // // collection_
    // bytes private collection_;

    // // bases_
    // bytes[] internal items_;

    /**
     * @notice gets unique attribtues based on given epoch and converts encoded bytes to object that can be merged
     */
    function _getItems(bytes32 seed) internal view returns (bytes[] memory res) {
        res = new bytes[](2);
        for (uint8 i = 0; i < res.length; i++) {
            res[i] = items_[((uint256(seed >> i) % (items_.length)))];
        }
    }
}