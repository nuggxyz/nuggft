// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

interface INuggftV1Proof {
    event Rotate(uint160 indexed tokenId, bytes32 proof);

    event Mint(uint160 indexed tokenId, uint96 value, bytes32 proof, bytes32 stake, bytes32 agency);

    function mint(uint160 tokenId) external payable;

    function trustedMint(uint160 tokenId, address to) external payable;

    // prettier-ignore
    function rotate(uint160 tokenId, uint8[] calldata from, uint8[] calldata to) external;

    function proofOf(uint160 tokenId) external view returns (uint256);

    function imageURI(uint256 tokenId) external view returns (string memory res);

    function itemURI(uint16 itemId) external view returns (string memory res);

    function featureLength(uint8 itemId) external view returns (uint8 res);
}
