// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Metadata} from './IDotnuggV1Metadata.sol';
import {IDotnuggV1StorageProxy} from './IDotnuggV1StorageProxy.sol';

interface IDotnuggV1Implementer {
    event DotnuggV1ConfigUpdated(uint256 indexed artifactId);

    function dotnuggV1ImplementerCallback(uint256 artifactId) external view returns (IDotnuggV1Metadata.Memory memory data);

    function dotnuggV1TrustCallback(address caller) external returns (bool);

    function dotnuggV1StorageProxy() external returns (IDotnuggV1StorageProxy res);
}
