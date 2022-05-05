// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

interface IDotnuggV1Resolver {
    function calc(uint256[][] memory reads) external view returns (uint256[] memory calculated, uint256 dat);

    function combo(uint256[][] memory reads, bool base64) external view returns (string memory data);

    function encodeJson(bytes memory input, bool base64) external pure returns (bytes memory data);

    function svg(
        uint256[] memory calculated,
        uint256 dat,
        bool base64
    ) external pure returns (string memory res);
}
