// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IDotnuggV1Resolver {
    function calc(uint256[][] memory reads) external view returns (uint256[] memory calculated);

    function combo(uint256[][] memory reads, bool base64) external view returns (string memory data);

    function calc(uint256[] memory read) external view returns (uint256[] memory calculated);

    function combo(uint256[] memory read, bool base64) external view returns (string memory data);

    function svg(uint256[] memory calculated, bool base64) external view returns (string memory data);
}
