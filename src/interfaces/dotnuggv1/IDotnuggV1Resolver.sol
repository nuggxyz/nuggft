// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {IDotnuggV1Metadata} from './IDotnuggV1Metadata.sol';

interface IDotnuggV1Resolver {
    function resolveBytes(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory data,
        uint8 zoom
    ) external view returns (bytes memory res);

    function resolveRaw(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory data,
        uint8 zoom
    ) external view returns (uint256[] memory res);

    function resolveMetadata(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory data,
        uint8 zoom
    ) external view returns (IDotnuggV1Metadata.Memory memory res);

    function resolveString(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory data,
        uint8 zoom
    ) external view returns (string memory res);

    function resolveUri(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory data,
        uint8 zoom
    ) external view returns (string memory res);
}
