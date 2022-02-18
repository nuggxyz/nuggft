// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IDotnuggV1File {
    function index(uint256 input) external view returns (uint256[] memory arr);
}
