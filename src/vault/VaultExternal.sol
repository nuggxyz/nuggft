// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {IVaultExternal} from '../interfaces/INuggFT.sol';
import {IERC721Metadata} from '../interfaces/IERC721.sol';
import {IPostProcessResolver, IProcessResolver, IPreProcessResolver} from '../interfaces/IResolver.sol';

import {VaultCore} from './VaultCore.sol';
import {VaultView} from './VaultView.sol';

import {TokenView} from '../token/TokenView.sol';

import {EpochView} from '../epoch/EpochView.sol';

import {ProofView} from '../proof/ProofView.sol';

abstract contract VaultExternal is IVaultExternal {
    using SafeCastLib for uint256;

    address public immutable defaultResolver;

    constructor(address _dr) {
        defaultResolver = _dr;
    }

    function setResolver(uint160 tokenId, address to) public view virtual override returns (address) {
        return VaultCore.setResolver(tokenId, to);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
        res = resolvedTokenURIString(
            tokenId,
            VaultView.hasResolver(tokenId.safe160()) ? VaultView.resolverOf(tokenId.safe160()) : defaultResolver
        );
    }

    function resolverOf(uint160 tokenId) public view virtual override returns (address) {
        return VaultView.resolverOf(tokenId);
    }

    function rawTokenURI(uint160 tokenId) public view returns (uint256[] memory res) {
        (, uint8[] memory ids, , uint8[] memory xovers, uint8[] memory yovers) = ProofView.parsedProofOfIncludingPending(tokenId);

        bytes memory data = abi.encode(tokenId, ids, xovers, yovers, address(this));

        uint256[][] memory files = VaultCore.getBatch(ids);

        res = IProcessResolver(defaultResolver).rawProcess(files, data);
    }

    function resolvedTokenURIString(uint256 tokenId, address resolver) public view returns (string memory res) {
        res = string(resolvedTokenURI(tokenId, resolver));
    }

    function resolvedTokenURI(uint256 tokenId, address resolver) public view returns (bytes memory res) {
        (, uint8[] memory ids, , uint8[] memory xovers, uint8[] memory yovers) = ProofView.parsedProofOfIncludingPending(tokenId);

        uint256[][] memory files = VaultCore.getBatch(ids);

        bytes memory data = abi.encode(tokenId, ids, xovers, yovers, address(this));

        // bytes memory customData = IPreProcessResolver(resolver).preProcess(data);

        res = IProcessResolver(resolver).resolvedProcess(files, resolver, data);

        // return IPostProcessResolver(resolver).postProcess(processedFile, data, customData);
    }
}
