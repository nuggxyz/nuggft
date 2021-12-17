// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IVaultExternal} from '../interfaces/INuggFT.sol';

import {IERC721Metadata} from '../interfaces/IERC721.sol';
import {IPostProcessResolver, IProcessResolver, IPreProcessResolver} from '../interfaces/IResolver.sol';

import {VaultCore} from './VaultCore.sol';

import {VaultView} from './VaultView.sol';
import {TokenView} from '../token/TokenView.sol';
import {EpochView} from '../epoch/EpochView.sol';
import {ProofView} from '../proof/ProofView.sol';

abstract contract VaultExternal is IVaultExternal {
    address public immutable defaultResolver;

    constructor(address _dr) {
        defaultResolver = _dr;
    }

    function resolverOf(uint256 tokenId) public view virtual override returns (address) {
        return VaultView.resolverOf(tokenId);
    }

    function addToVault(uint256[][][] calldata data) external {
        VaultCore.set(data);
    }

    function rawProcessURI(uint256 tokenId) public view returns (uint256[] memory res) {
        require(TokenView.exists(tokenId) || tokenId == EpochView.activeEpoch(), 'NFT:NTM:0');

        (, uint256[] memory ids, , uint256[] memory overrides) = ProofView.parsedProofOfIncludingPending(tokenId);

        bytes memory data = abi.encode(tokenId, ids, overrides, address(this));

        uint256[][] memory files = VaultCore.getBatch(ids);

        res = IProcessResolver(defaultResolver).process(files, data, '');
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory res) {
        res = string(tokenURI(tokenId, VaultView.hasResolver(tokenId) ? VaultView.resolverOf(tokenId) : defaultResolver));
    }

    function tokenURI(uint256 tokenId, address resolver) public view returns (bytes memory res) {
        require(ProofView.hasProof(tokenId) || tokenId == EpochView.activeEpoch(), 'NFT:NTM:0');

        (, uint256[] memory ids, , uint256[] memory overrides) = ProofView.parsedProofOfIncludingPending(tokenId);

        uint256[][] memory files = VaultCore.getBatch(ids);

        bytes memory data = abi.encode(tokenId, ids, overrides, address(this));

        bytes memory customData = IPreProcessResolver(resolver).preProcess(data);

        uint256[] memory processedFile = IProcessResolver(resolver).process(files, data, customData);

        return IPostProcessResolver(resolver).postProcess(processedFile, data, customData);
    }
}
