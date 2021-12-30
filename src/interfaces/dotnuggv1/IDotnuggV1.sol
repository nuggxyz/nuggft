// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Metadata} from './IDotnuggV1Metadata.sol';
import {IDotnuggV1Resolver} from './IDotnuggV1Resolver.sol';
import {IDotnuggV1Storage} from './IDotnuggV1Storage.sol';

interface IDotnuggV1 is IDotnuggV1Resolver, IDotnuggV1Storage {
    function process(
        address implementer,
        uint256 tokenId,
        uint8 width
    ) external view returns (uint256[] memory file, IDotnuggV1Metadata.Memory memory dat);

    function dotnuggToBytes(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (address resolvedBy, bytes memory res);

    function dotnuggToRaw(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (address resolvedBy, uint256[] memory res);

    function dotnuggToMetadata(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (address resolvedBy, IDotnuggV1Metadata.Memory memory res);

    function dotnuggToString(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (address resolvedBy, string memory res);

    function dotnuggToUri(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (address resolvedBy, string memory res);
}
