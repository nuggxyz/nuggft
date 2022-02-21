// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

interface INuggftV1Proof {
    event Rotate(uint160 indexed tokenId, bytes32 proof);

    // prettier-ignore
    function rotate(uint160 tokenId, uint8[] calldata index0s, uint8[] calldata index1s) external;

    function proofOf(uint160 tokenId) external view returns (uint256);

    function imageURI(uint256 tokenId) external view returns (string memory res);
}
