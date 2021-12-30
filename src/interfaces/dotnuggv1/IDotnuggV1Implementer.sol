// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Metadata} from './IDotnuggV1Metadata.sol';

interface IDotnuggV1Implementer {
    function dotnuggV1Callback(uint256 tokenId) external view returns (IDotnuggV1Metadata.Memory memory data);

    function dotnuggV1StoreFiles(uint256[][] calldata data, uint8 feature) external;
}
