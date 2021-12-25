// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Data} from './IDotnuggV1Data.sol';

interface IDotnuggV1Implementer {
    function setResolver(uint256 tokenId, address to) external;

    function resolverOf(uint256 tokenId) external view returns (address resolver);

    function storeFiles(uint256[][] calldata data, uint8 feature) external;

    function prepareFiles(uint256 tokenId) external view returns (IDotnuggV1Data.Data memory data);

    function dotnuggV1Processor() external returns (address);

    function defaultWidth() external returns (uint8);

    function defaultZoom() external returns (uint8);
}
