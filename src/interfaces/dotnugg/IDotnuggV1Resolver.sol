// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

interface IDotnuggV1Resolver {
    function calc(uint256[][] memory reads) external view returns (uint256[] memory calculated);

    function combo(uint256[][] memory reads, bool base64) external view returns (string memory data);

    function calc(uint256[] memory read) external view returns (uint256[] memory calculated);

    function combo(uint256[] memory read, bool base64) external view returns (string memory data);

    function svg(uint256[] memory calculated, bool base64) external view returns (string memory data);

    function svg(uint256[] memory calculated) external view returns (string memory data);

    function encodeJsonAsBase64(bytes memory input) external pure returns (bytes memory data);

    function encodeJsonAsUtf8(bytes memory input) external pure returns (bytes memory data);

    function encodeSvgAsBase64(bytes memory input) external pure returns (bytes memory data);

    function encodeSvgAsUtf8(bytes memory input) external pure returns (bytes memory data);

    function props(uint8[8] memory ids, string[8] memory labels) external pure returns (string memory);

    function props(uint256 proof, string[8] memory labels) external pure returns (string memory);

    function decodeProof(uint256 input) external pure returns (uint16[16] memory res);

    function encodeProof(uint8[8] memory ids) external pure returns (uint256 proof);

    function encodeProof(uint16[16] memory ids) external pure returns (uint256 proof);
}
