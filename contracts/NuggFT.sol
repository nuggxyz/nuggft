// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/Base64.sol';
import './libraries/SeedMath.sol';
import './libraries/Uint.sol';

import './common/Launchable.sol';
import './core/Seedable.sol';
import './core/Epochable.sol';

import './erc721/ERC721.sol';
import './interfaces/IDotNuggFileResolver.sol';
import './interfaces/IDotNuggColorResolver.sol';

import './interfaces/IDotNugg.sol';
import './interfaces/INuggFT.sol';
import './auction/NuggMinter.sol';
import './auction/NuggSeller.sol';

/**
 * @title Nugg Labs NFT Collection 0 - "NuggFT"
 * @author Nugg Labs - @danny7even & @dub6ix - 2021
 * @notice entrily onchain generative NFT and stakable auction contract
 * @dev this is art
 *
 * Note: epochs correlate directly to tokenIDs
 * Note: no images are stored in their final form - they are generated by view/pure functions at query time completly onchain
 * Note: the block hash corresponding to the start of an epoch is used as the "random" seed
 * Note: epochs are 256 blocks long as block hashes only exist for 256 blocks
 */
contract NuggFT is INuggFT, ERC721, Mutexable, Launchable {
    using SeedMath for bytes32;
    using Uint256 for uint256;

    IDotNugg internal _DOTNUGG;
    INuggMinter internal _MINTER;
    INuggSeller internal _SELLER;
    IDotNuggFileResolver internal _DEFAULT_NUGGIN;

    Mutex transfer;

    constructor() ERC721('Nugg Fungable Token', 'NuggFT') {
        transfer = initMutex();
    }

    function onMinterClaim(address minter, uint256 tokenId) external override lock(transfer) {
        require(msg_sender() == address(_MINTER), 'NFT:OMC:0');
        _safeMint(minter, tokenId);
    }

    function onBuyerClaim(address buyer, uint256 tokenId) external override lock(transfer) {
        require(msg_sender() == address(_SELLER), 'NFT:OBC:0');
        _safeTransfer(address(_SELLER), buyer, tokenId, '');
    }

    function _beforeTokenTransfer(
        address,
        address,
        uint256
    ) internal view override {
        require(msg_sender() == address(_MINTER) || msg_sender() == address(_SELLER), 'NFT:BTT:0');
    }

    /**
     * @notice inializes contract outside of constructor
     * @inheritdoc Launchable
     */
    function launch(bytes memory data) public override {
        super.launch(data);
        (address nuggeth, address dotnugg, address minter, address seller, address nuggin) = abi.decode(data, (address, address, address, address, address));
        _DOTNUGG = IDotNugg(dotnugg);
        _MINTER = INuggMinter(minter);
        _SELLER = INuggSeller(seller);
        _DEFAULT_NUGGIN = IDotNuggFileResolver(nuggin);

        require(_DEFAULT_NUGGIN.supportsInterface(type(IDotNuggFileResolver).interfaceId), 'NUG:LAUNCH:0');
    }

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 tokenId) public view override isLaunched returns (string memory res) {
        require(_MINTER.seedExists(tokenId), 'NUG:TURI:0');
        res = _generateTokenURI(tokenId, _MINTER.getSeed(tokenId).toUint256(), address(_DEFAULT_NUGGIN));
    }

    function tokenURI(uint256 tokenId, address resolver) public view isLaunched returns (string memory res) {
        require(_MINTER.seedExists(tokenId), 'NUG:TURI:1');
        res = _generateTokenURI(tokenId, _MINTER.getSeed(tokenId).toUint256(), resolver);
    }

    /**
     * @notice equivilent of tokenURI function, but for only for active epoch as real uri does not exist yet
     */
    function pendingTokenURI() public view override isLaunched returns (string memory res) {
        uint256 id = _MINTER.currentEpochId();
        bytes32 seed = _MINTER.seedExists(id) ? _MINTER.getSeed(id) : _MINTER.calculateCurrentSeed();
        res = _generateTokenURI(id, seed.toUint256(), address(_DEFAULT_NUGGIN));
    }

    /**
     * @notice calcualtes the token uri for a given epoch
     */
    function _generateTokenURI(
        uint256 epoch,
        uint256 seed,
        address resolver
    ) internal view returns (string memory) {
        string memory uriName = string(abi.encodePacked('NuggFT #', epoch.toString()));
        string memory uriDesc = 'TDB';

        string memory uriImage = _DOTNUGG.nuggify(collection_, _getItems(seed), resolver, "");

        return
            string(
                abi.encodePacked(
                    Base64.encodeJson(bytes(abi.encodePacked('{"name":"', uriName, '","description":"', uriDesc, '", "image": "', uriImage, '"}')))
                )
            );
    }

    // collection_
    bytes private collection_;

    // bases_
    bytes[] internal items_;

    /**
     * @notice gets unique attribtues based on given epoch and converts encoded bytes to object that can be merged
     */
    function _getItems(uint256 seed) internal view returns (bytes[] memory res) {
        res = new bytes[](5);
        for (uint8 i = 0; i < res.length * 2; i++) {
            res[i] = items_[uint16((seed >> i) % items_.length)];
        }
    }
}
