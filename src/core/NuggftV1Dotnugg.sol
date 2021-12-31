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

        uint256 newLen = _lengthOf(cache, feature) + len;

        featureLengths = ShiftLib.set(cache, 8, feature * 8, newLen);
    }

    function lengthOf(uint8 feature) external view returns (uint8) {
        return _lengthOf(featureLengths, feature);
    }

    function _lengthOf(uint256 cache, uint8 feature) internal pure returns (uint8) {
        return uint8(ShiftLib.get(cache, 8, feature * 8));
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
