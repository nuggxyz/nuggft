// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IdotnuggV1Processor} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Resolver} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Data} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Implementer} from '../interfaces/IdotnuggV1.sol';
import {IERC721Metadata} from '../interfaces/IERC721.sol';

import {IFileExternal} from '../interfaces/nuggft/IFileExternal.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {TokenView} from '../token/TokenView.sol';
import {ProofCore} from '../proof/ProofCore.sol';

import {FileCore} from './FileCore.sol';
import {FileView} from './FileView.sol';
import {File} from './FileStorage.sol';

import {Trust} from '../trust/Trust.sol';

abstract contract FileExternal is IFileExternal {
    using SafeCastLib for uint256;

    /// @inheritdoc IdotnuggV1Implementer
    address public override dotnuggV1Processor;

    /// @inheritdoc IdotnuggV1Implementer
    uint8 public override defaultWidth = 45;

    // / @inheritdoc IdotnuggV1Implementer
    uint8 public override defaultZoom = 10;

    constructor(address _dotnuggV1Processor) {
        require(_dotnuggV1Processor != address(0), 'F:4');
        dotnuggV1Processor = _dotnuggV1Processor;
    }

    /// @inheritdoc IFileExternal
    function storeFiles(uint256[][] calldata data, uint8 feature) external override {
        Trust.check();

        FileCore.storeFiles(feature, data);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            RESOLVER MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IdotnuggV1Implementer
    function setResolver(uint256 tokenId, address to) public virtual override {
        require(TokenView.isOperatorForOwner(msg.sender, tokenId.safe160()), 'F:5');

        File.spointer().resolvers[tokenId] = to;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            MAIN FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
        uint160 safeTokenId = tokenId.safe160();

        address resolver = FileView.hasResolver(safeTokenId) ? FileView.resolverOf(safeTokenId) : dotnuggV1Processor;

        res = IdotnuggV1Processor(dotnuggV1Processor).dotnuggToString(address(this), tokenId, resolver, defaultWidth, defaultZoom);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                HELPERS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IdotnuggV1Implementer
    function prepareFiles(uint256 tokenId) public view override returns (uint256[][] memory input, IdotnuggV1Data.Data memory data) {
        (uint256 proof, uint8[] memory ids, uint8[] memory extras, uint8[] memory xovers, uint8[] memory yovers) = ProofCore
            .parsedProofOfIncludingPending(tokenId.safe160());

        input = FileCore.getBatchFiles(ids);

        data = IdotnuggV1Data.Data({
            version: 1,
            renderedAt: block.timestamp,
            name: 'NuggFT V1',
            desc: 'Nugg Fungible Token V1',
            owner: TokenView.exists(tokenId.safe160()) ? TokenView.ownerOf(tokenId.safe160()) : address(0),
            tokenId: tokenId,
            proof: proof,
            ids: ids,
            extras: extras,
            xovers: xovers,
            yovers: yovers
        });
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IdotnuggV1Implementer
    function resolverOf(uint256 tokenId) public view virtual override returns (address) {
        return FileView.resolverOf(tokenId.safe160());
    }

    /// @inheritdoc IFileExternal
    function totalLengths() public view override returns (uint8[] memory res) {
        res = FileView.totalLengths();
    }
}
