// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1StorageProxy} from '../interfaces/dotnuggv1/IDotnuggV1StorageProxy.sol';

import {IDotnuggV1} from '../interfaces/dotnuggv1/IDotnuggV1.sol';
import {IDotnuggV1Metadata} from '../interfaces/dotnuggv1/IDotnuggV1Metadata.sol';
import {IDotnuggV1Resolver} from '../interfaces/dotnuggv1/IDotnuggV1Resolver.sol';
import {IDotnuggV1Implementer} from '../interfaces/dotnuggv1/IDotnuggV1Implementer.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {INuggftV1Dotnugg} from '../interfaces/nuggftv1/INuggftV1Dotnugg.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {NuggftV1Token} from './NuggftV1Token.sol';

import {Trust} from './Trust.sol';

abstract contract NuggftV1Dotnugg is INuggftV1Dotnugg, NuggftV1Token, Trust {
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

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

    constructor(address) {
        (bool ok, bytes memory res) = address(
            uint160(
                uint256(
                    keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), msg.sender, bytes1(0x02))) //
                )
            ) //
        ).call(abi.encodeWithSelector(bytes4(0x8e3b3a6b)));

        require(ok);

        dotnuggV1 = IDotnuggV1(abi.decode(res, (address)));

        dotnuggV1StorageProxy = dotnuggV1.register();
    }

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

    /// @inheritdoc INuggftV1Dotnugg
    function dotnuggV1StoreFiles(uint256[][] calldata data, uint8 feature) external requiresTrust {
        // uint8 len = dotnuggV1StorageProxy.store(feature, data);
        // uint256 cache = featureLengths;
        // uint256 newLen = _lengthOf(cache, feature) + len;
        // featureLengths = ShiftLib.set(cache, 8, feature * 8, newLen);
    }

    function lengthOf(uint8 feature) external view returns (uint8) {
        return _lengthOf(featureLengths, feature);
    }

    function _lengthOf(uint256 cache, uint8 feature) internal pure returns (uint8) {
        return uint8(ShiftLib.get(cache, 8, feature * 8));
    }

    /// @inheritdoc INuggftV1Dotnugg
    function setDotnuggV1Resolver(uint256 tokenId, address to) public virtual override {
        require(_isOperatorForOwner(msg.sender, tokenId.safe160()), 'F:5');

        resolvers[tokenId] = to;

        emit DotnuggV1ConfigUpdated(tokenId);
    }

    /// @inheritdoc INuggftV1Dotnugg
    function dotnuggV1ResolverOf(uint256 tokenId) public view virtual override returns (address) {
        return resolvers[tokenId.safe160()];
    }

    /// @inheritdoc INuggftV1Dotnugg
    function setDotnuggV1AnchorOverrides(
        uint160 tokenId,
        uint16 itemId,
        uint256 x,
        uint256 y
    ) external override {
        require(x < 64 && y < 64, 'UNTEESTED:1');

        ensureOperatorForOwner(msg.sender, tokenId);

        settings[tokenId].anchorOverrides[itemId] = x | (y << 6);

        emit DotnuggV1ConfigUpdated(tokenId);
    }

    /// @inheritdoc INuggftV1Dotnugg
    function setDotnuggV1Background(uint160 tokenId, string memory s) external override {
        ensureOperatorForOwner(msg.sender, tokenId);

        settings[tokenId].background = s;

        emit DotnuggV1ConfigUpdated(tokenId);
    }

    /// @inheritdoc INuggftV1Dotnugg
    function setDotnuggV1Style(
        uint160 tokenId,
        uint16 itemId,
        string memory s
    ) external override {
        ensureOperatorForOwner(msg.sender, tokenId);

        settings[tokenId].styles[itemId] = s;

        emit DotnuggV1ConfigUpdated(tokenId);
    }

    function hasResolver(uint160 tokenId) internal view returns (bool) {
        return resolvers[tokenId] != address(0);
    }
}
