// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {IDotnuggV1StorageProxy} from '../interfaces/dotnuggv1/IDotnuggV1StorageProxy.sol';

import {IDotnuggV1} from '../interfaces/dotnuggv1/IDotnuggV1.sol';
import {IDotnuggV1Metadata} from '../interfaces/dotnuggv1/IDotnuggV1Metadata.sol';
import {IDotnuggV1Resolver} from '../interfaces/dotnuggv1/IDotnuggV1Resolver.sol';
import {IDotnuggV1Implementer} from '../interfaces/dotnuggv1/IDotnuggV1Implementer.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {INuggftV1Dotnugg} from '../interfaces/nuggftv1/INuggftV1Dotnugg.sol';
import {CastLib} from '../libraries/CastLib.sol';
import {NuggftV1Token} from './NuggftV1Token.sol';

import {NuggftV1Trust} from './NuggftV1Trust.sol';

/// @custom:testing test each function
abstract contract NuggftV1Dotnugg is INuggftV1Dotnugg, NuggftV1Token, NuggftV1Trust {
    using CastLib for uint256;
    using CastLib for uint16;

    struct Settings {
        mapping(uint256 => uint256) anchorOverrides;
        mapping(uint256 => string) styles;
        string background;
    }

    mapping(uint160 => Settings) settings;

    /// @inheritdoc IDotnuggV1Implementer
    IDotnuggV1StorageProxy public override dotnuggV1StorageProxy;

    /// @inheritdoc INuggftV1Dotnugg
    IDotnuggV1 public override dotnuggV1;

    mapping(uint256 => address) resolvers;

    uint256 internal featureLengths;

    /// @inheritdoc IDotnuggV1Implementer
    function dotnuggV1StoreCallback(
        address caller,
        uint8 feature,
        uint8 amount,
        address
    ) external override(IDotnuggV1Implementer) returns (bool ok) {
        require(msg.sender == address(dotnuggV1StorageProxy), 'D:0');

        ok = isTrusted[caller];

        if (!ok) return false;

        uint256 cache = featureLengths;

        uint256 newLen = _lengthOf(cache, feature) + amount;

        featureLengths = ShiftLib.set(cache, 8, feature * 8, newLen);
    }

    function lengthOf(uint8 feature) external view returns (uint8) {
        return _lengthOf(featureLengths, feature);
    }

    function _lengthOf(uint256 cache, uint8 feature) internal pure returns (uint8) {
        return uint8(ShiftLib.get(cache, 8, feature * 8));
    }

    /// @inheritdoc INuggftV1Dotnugg
    function setDotnuggV1Resolver(uint256 tokenId, address to) public virtual override {
        require(isAgent(msg.sender, uint160(tokenId)), 'F:5');

        resolvers[tokenId] = to;

        emit DotnuggV1ConfigUpdated(tokenId);
    }

    /// @inheritdoc INuggftV1Dotnugg
    function dotnuggV1ResolverOf(uint256 tokenId) public view virtual override returns (address) {
        return resolvers[tokenId.to160()];
    }

    /// @inheritdoc INuggftV1Dotnugg
    function setDotnuggV1AnchorOverrides(
        uint160 tokenId,
        uint16 itemId,
        uint256 x,
        uint256 y
    ) external override {
        require(x < 64 && y < 64, 'UNTEESTED:1');

        require(isAgent(msg.sender, tokenId), hex'50');

        settings[tokenId].anchorOverrides[itemId] = x | (y << 6);

        emit DotnuggV1ConfigUpdated(tokenId);
    }

    /// @inheritdoc INuggftV1Dotnugg
    function setDotnuggV1Background(uint160 tokenId, string memory s) external override {
        require(isAgent(msg.sender, tokenId), hex'51');

        settings[tokenId].background = s;

        emit DotnuggV1ConfigUpdated(tokenId);
    }

    /// @inheritdoc INuggftV1Dotnugg
    function setDotnuggV1Style(
        uint160 tokenId,
        uint16 itemId,
        string memory s
    ) external override {
        require(isAgent(msg.sender, tokenId), hex'52');

        settings[tokenId].styles[itemId] = s;

        emit DotnuggV1ConfigUpdated(tokenId);
    }

    function hasResolver(uint160 tokenId) internal view returns (bool) {
        return resolvers[tokenId] != address(0);
    }
}
