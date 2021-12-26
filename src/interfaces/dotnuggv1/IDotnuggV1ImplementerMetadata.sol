// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IDotnuggV1ImplementerMetadata {
    event DotnuggV1ResolverUpdated(uint256 tokenId, address to);

    function setDotnuggV1Resolver(uint256 tokenId, address to) external;

    function dotnuggV1ResolverOf(uint256 tokenId) external view returns (address resolver);

    function dotnuggV1Processor() external returns (address);

    function dotnuggV1DefaultWidth() external returns (uint8);

    function dotnuggV1DefaultZoom() external returns (uint8);
}
