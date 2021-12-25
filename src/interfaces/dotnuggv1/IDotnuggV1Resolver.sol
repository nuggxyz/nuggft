// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Data} from './IDotnuggV1Data.sol';

interface IDotnuggV1Resolver {
    function resolveBytes(
        uint256[] memory file,
        IDotnuggV1Data.Data memory data,
        uint8 zoom
    ) external view returns (bytes memory res);

    function resolveRaw(
        uint256[] memory file,
        IDotnuggV1Data.Data memory data,
        uint8 zoom
    ) external view returns (uint256[] memory res);

    function resolveData(
        uint256[] memory file,
        IDotnuggV1Data.Data memory data,
        uint8 zoom
    ) external view returns (IDotnuggV1Data.Data memory res);

    function resolveString(
        uint256[] memory file,
        IDotnuggV1Data.Data memory data,
        uint8 zoom
    ) external view returns (string memory res);
}