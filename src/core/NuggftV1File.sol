// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Storage} from '../interfaces/dotnuggv1/IDotnuggV1Storage.sol';

import {IDotnuggV1Data} from '../interfaces/dotnuggv1/IDotnuggV1Data.sol';
import {IDotnuggV1Resolver} from '../interfaces/dotnuggv1/IDotnuggV1Resolver.sol';
import {IDotnuggV1Processor} from '../interfaces/dotnuggv1/IDotnuggV1Processor.sol';
import {IDotnuggV1Implementer} from '../interfaces/dotnuggv1/IDotnuggV1Implementer.sol';
import {IERC721Metadata} from '../interfaces/IERC721.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {INuggftV1File} from '../interfaces/nuggftv1/INuggftV1File.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {NuggftV1Token} from './NuggftV1Token.sol';

import {Trust} from './Trust.sol';

abstract contract NuggftV1File is INuggftV1File, NuggftV1Token, Trust {
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    /// @inheritdoc IDotnuggV1Implementer
    address public override dotnuggV1Processor;

    /// @inheritdoc IDotnuggV1Implementer
    uint8 public override defaultWidth = 45;

    // / @inheritdoc IDotnuggV1Implementer
    uint8 public override defaultZoom = 10;

    mapping(uint8 => uint168[]) sstore2Pointers;
    // Mapping from token ID to owner address

    mapping(uint256 => address) resolvers;

    uint256 internal featureLengths;

    constructor(address _dotnuggV1Processor) {
        require(_dotnuggV1Processor != address(0), 'F:4');
        dotnuggV1Processor = _dotnuggV1Processor;
    }

    /// @inheritdoc IDotnuggV1Implementer
    function storeFiles(uint256[][] calldata data, uint8 feature) external override requiresTrust {
        uint8 len = IDotnuggV1Storage(dotnuggV1Processor).storeFiles(feature, data);

        uint256 cache = featureLengths;

        // featureLengthOf[feature] += len;

        uint8[] memory lengths = ShiftLib.getArray(cache, 0);

        lengths[feature] += len;

        featureLengths = ShiftLib.setArray(cache, 0, lengths);
    }

    /// @inheritdoc IDotnuggV1Implementer
    function setResolver(uint256 tokenId, address to) public virtual override {
        require(_isOperatorForOwner(msg.sender, tokenId.safe160()), 'F:5');

        resolvers[tokenId] = to;
    }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
        uint160 safeTokenId = tokenId.safe160();

        address resolver = hasResolver(safeTokenId) ? resolverOf(safeTokenId) : dotnuggV1Processor;

        res = IDotnuggV1Processor(dotnuggV1Processor).dotnuggToString(address(this), tokenId, resolver, defaultWidth, defaultZoom);
    }

    /// @inheritdoc IDotnuggV1Implementer
    function resolverOf(uint256 tokenId) public view virtual override returns (address) {
        return resolverOf(tokenId.safe160());
    }

    function hasResolver(uint160 tokenId) internal view returns (bool) {
        return resolvers[tokenId] != address(0);
    }
}
