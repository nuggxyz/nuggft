// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

interface INuggftV1Proof {
    event Rotate(uint24 indexed tokenId, bytes32 proof);

    function proofOf(uint24 tokenId) external view returns (uint256 res);

    // prettier-ignore
    function rotate(uint24 tokenId, uint8[] calldata from, uint8[] calldata to) external;

    function imageURI(uint256 tokenId) external view returns (string memory);

    function imageSVG(uint256 tokenId) external view returns (string memory);

    function image123(
        uint256 tokenId,
        bool base64,
        uint8 chunk,
        bytes memory prev
    ) external view returns (bytes memory res);
}
