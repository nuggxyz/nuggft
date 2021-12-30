// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Storage} from '../interfaces/dotnuggv1/IDotnuggV1Storage.sol';

import {IDotnuggV1Metadata} from '../interfaces/dotnuggv1/IDotnuggV1Metadata.sol';
import {IDotnuggV1Resolver} from '../interfaces/dotnuggv1/IDotnuggV1Resolver.sol';
import {IDotnuggV1Implementer} from '../interfaces/dotnuggv1/IDotnuggV1Implementer.sol';
import {IDotnuggV1ImplementerMetadata} from '../interfaces/dotnuggv1/IDotnuggV1ImplementerMetadata.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {INuggftV1Dotnugg} from '../interfaces/nuggftv1/INuggftV1Dotnugg.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {NuggftV1Token} from './NuggftV1Token.sol';

import {Trust} from './Trust.sol';

abstract contract NuggftV1Dotnugg is INuggftV1Dotnugg, NuggftV1Token, Trust {
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    /// @inheritdoc IDotnuggV1ImplementerMetadata
    address public override dotnuggV1Processor;

    /// @inheritdoc IDotnuggV1ImplementerMetadata
    uint8 public override dotnuggV1DefaultWidth = 45;

    /// @inheritdoc IDotnuggV1ImplementerMetadata
    uint8 public override dotnuggV1DefaultZoom = 10;

    mapping(uint8 => uint168[]) sstore2Pointers;
    // Mapping from token ID to owner address

    mapping(uint256 => address) resolvers;

    uint256 internal featureLengths;

    constructor(address _dotnuggV1Processor) {
        require(_dotnuggV1Processor != address(0), 'F:4');
        dotnuggV1Processor = _dotnuggV1Processor;
    }

    /// @inheritdoc IDotnuggV1Implementer
    function dotnuggV1StoreFiles(uint256[][] calldata data, uint8 feature) external override requiresTrust {
        uint8 len = IDotnuggV1Storage(dotnuggV1Processor).store(feature, data);

        uint256 cache = featureLengths;

        uint8[] memory lengths = ShiftLib.getArray(cache, 0);

        lengths[feature] += len;

        featureLengths = ShiftLib.setArray(cache, 0, lengths);
    }

    /// @inheritdoc IDotnuggV1ImplementerMetadata
    function setDotnuggV1Resolver(uint256 tokenId, address to) public virtual override {
        require(_isOperatorForOwner(msg.sender, tokenId.safe160()), 'F:5');

        resolvers[tokenId] = to;

        emit DotnuggV1ResolverUpdated(tokenId, to);
    }

    /// @inheritdoc IDotnuggV1ImplementerMetadata
    function dotnuggV1ResolverOf(uint256 tokenId) public view virtual override returns (address) {
        return resolvers[tokenId.safe160()];
    }

    function hasResolver(uint160 tokenId) internal view returns (bool) {
        return resolvers[tokenId] != address(0);
    }
}
