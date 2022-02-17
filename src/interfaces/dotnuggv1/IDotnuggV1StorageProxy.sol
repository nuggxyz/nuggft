// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IDotnuggV1StorageProxy {
    function stored(uint8 feature) external view returns (uint8);

    function store(uint8 feature, bytes memory data) external returns (uint8 amount);

    function unsafeBulkStore(bytes[] calldata data) external;

    function pointers() external view returns (address[][] memory res);

    function init(address _implementer) external;

    function getBatch(uint8[] memory ids) external view returns (uint256[][] memory data);

    function get(uint8 feature, uint8 pos) external view returns (uint256[] memory data);
}