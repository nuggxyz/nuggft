// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IdotnuggV1Data {
    struct Data {
        uint256 version;
        uint256 renderedAt;
        string name;
        string desc;
        address owner;
        uint256 tokenId;
        uint256 proof;
        uint8[] ids;
        uint8[] extras;
        uint8[] xovers;
        uint8[] yovers;
    }
}

interface IdotnuggV1Resolver {
    function resolveBytes(
        uint256[] memory file,
        IdotnuggV1Data.Data memory data,
        uint8 zoom
    ) external view returns (bytes memory res);

    function resolveRaw(
        uint256[] memory file,
        IdotnuggV1Data.Data memory data,
        uint8 zoom
    ) external view returns (uint256[] memory res);

    function resolveData(
        uint256[] memory file,
        IdotnuggV1Data.Data memory data,
        uint8 zoom
    ) external view returns (IdotnuggV1Data.Data memory res);

    function resolveString(
        uint256[] memory file,
        IdotnuggV1Data.Data memory data,
        uint8 zoom
    ) external view returns (string memory res);
}

interface IdotnuggV1Processor is IdotnuggV1Resolver {
    function dotnuggToBytes(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (bytes memory res);

    function dotnuggToRaw(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (uint256[] memory res);

    function dotnuggToData(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (IdotnuggV1Data.Data memory res);

    function dotnuggToString(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (string memory res);

    function process(
        address implementer,
        uint256 tokenId,
        uint8 width
    ) external view returns (uint256[] memory file, IdotnuggV1Data.Data memory dat);

    function processCore(
        uint256[][] memory files,
        IdotnuggV1Data.Data memory data,
        uint8 width
    ) external view returns (uint256[] memory file);
}

interface IdotnuggV1Implementer {
    function setResolver(uint256 tokenId, address to) external;

    function resolverOf(uint256 tokenId) external view returns (address resolver);

    function prepareFiles(uint256 tokenId) external view returns (uint256[][] memory file, IdotnuggV1Data.Data memory data);

    function dotnuggV1Processor() external returns (address);

    function defaultWidth() external returns (uint8);

    function defaultZoom() external returns (uint8);
}
