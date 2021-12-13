// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './interfaces/INuggFT.sol';
import './interfaces/IResolver.sol';

import './token/Token.sol';
import './token/Tokenable.sol';
import './swap/Swapable.sol';
import './stake/Stakeable.sol';
import './swap/Swap.sol';

contract NuggFT is INuggFT, Tokenable, Swapable, Stakeable {
    using EpochLib for uint256;
    using Vault for Vault.Storage;
    using Token for Token.Storage;
    using TokenLib for Token.Storage;

    address public immutable override defaultResolver;

    uint256 internal immutable _genesis;

    Token.Storage internal _nuggft;

    constructor(address _defaultResolver) Tokenable('NUGGFT', 'Nugg Fungible Token') {
        defaultResolver = _defaultResolver;

        _genesis = block.number;

        emit Genesis();
    }

    function nuggft() internal view override(Swapable, Tokenable, Stakeable) returns (Token.Storage storage) {
        return _nuggft;
    }

    function genesis() public view override(Swapable, ISwapable, Tokenable) returns (uint256) {
        return _genesis;
    }

    function addToVault(uint256[][] calldata data) external {
        _nuggft._vault.set(data);
    }

    function rawProcessURI(uint256 tokenId) public view returns (uint256[] memory res) {
        require(_nuggft._exists(tokenId) || tokenId == _genesis.activeEpoch(), 'NFT:NTM:0');

        (, uint256[] memory ids, , uint256[] memory overrides) = _nuggft._exists(tokenId) ? parsedProofOf(tokenId) : ProofLib.pendingProof(_nuggft, _genesis);

        bytes memory data = abi.encode(tokenId, ids, overrides, address(this));

        uint256[][] memory files = _nuggft._vault.getBatch(ids);

        res = IProcessResolver(defaultResolver).process(files, data, '');
    }

    function tokenURI(uint256 tokenId) public view override(IERC721Metadata, Tokenable) returns (string memory res) {
        res = string(tokenURI(tokenId, _nuggft._hasResolver(tokenId) ? _nuggft._resolverOf(tokenId) : defaultResolver));
    }

    function tokenURI(uint256 tokenId, address resolver) public view returns (bytes memory res) {
        require(_nuggft._exists(tokenId) || tokenId == _genesis.activeEpoch(), 'NFT:NTM:0');

        (, uint256[] memory ids, , uint256[] memory overrides) = _nuggft._exists(tokenId) ? parsedProofOf(tokenId) : ProofLib.pendingProof(_nuggft, _genesis);

        uint256[][] memory files = _nuggft._vault.getBatch(ids);

        bytes memory data = abi.encode(tokenId, ids, overrides, address(this));

        bytes memory customData = IPreProcessResolver(resolver).preProcess(data);

        uint256[] memory processedFile = IProcessResolver(resolver).process(files, data, customData);

        return IPostProcessResolver(resolver).postProcess(processedFile, data, customData);
    }
}
