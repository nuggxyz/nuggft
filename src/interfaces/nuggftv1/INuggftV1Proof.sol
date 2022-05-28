// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

interface INuggftV1Proof {
    event Rotate(uint24 indexed tokenId, bytes32 proof);

    event Mint(uint24 indexed tokenId, uint96 value, bytes32 proof, bytes32 stake, bytes32 agency);

    event PreMint(uint24 indexed tokenId, uint96 value, bytes32 proof, bytes32 agency);

    function mint(uint24 tokenId) external payable;

    function proofOf(uint24 tokenId) external view returns (uint256 res);

    function trustedMint(uint24 tokenId, address to) external payable;

    // prettier-ignore
    function rotate(uint24 tokenId, uint8[] calldata from, uint8[] calldata to) external;

    function imageURI(uint256 tokenId) external view returns (string memory);

    function imageSVG(uint256 tokenId) external view returns (string memory);

    // function imageSVG(
    //     uint256 tokenId,
    //     bool base64,
    //     uint8 chunks,
    //     uint8 index
    // ) external view returns (string memory res);

    function image123(
        uint256 tokenId,
        bool base64,
        uint8 chunk,
        bytes memory prev
    ) external view returns (bytes memory res);
}
