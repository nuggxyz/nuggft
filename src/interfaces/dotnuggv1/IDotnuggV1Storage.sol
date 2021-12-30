// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IDotnuggV1Storage {
    function stored(address implementer, uint8 feature) external view returns (uint8);

    function store(uint8 feature, uint256[][] calldata data) external returns (uint8 amount);

    function unsafeBulkStore(uint256[][][] calldata data) external;
}
