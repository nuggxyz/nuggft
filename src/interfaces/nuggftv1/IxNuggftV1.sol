// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

interface IxNuggftV1 {
    function imageURI(uint256 tokenId) external view returns (string memory);

    function imageSVG(uint256 tokenId) external view returns (string memory);

    function featureSupply(uint8 itemId) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function rarity(uint256 tokenId) external view returns (uint16 res);

    function transferBatch(
        uint256 proof,
        address from,
        address to
    ) external payable;

    function transferSingle(
        uint256 itemId,
        address from,
        address to
    ) external payable;
}
