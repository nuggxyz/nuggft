// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IdotnuggV1Data {
    struct Data {
        uint256 version;
        uint8 size;
        uint8 zoom;
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
    function resolveBytes(uint256[] memory file, IdotnuggV1Data.Data memory data) external view returns (bytes memory res);

    function resolveRaw(uint256[] memory file, IdotnuggV1Data.Data memory data) external view returns (uint256[] memory res);

    function resolveData(uint256[] memory file, IdotnuggV1Data.Data memory data) external view returns (IdotnuggV1Data.Data memory res);

    function resolveString(uint256[] memory file, IdotnuggV1Data.Data memory data) external view returns (string memory res);
}

interface IdotnuggV1Processer is IdotnuggV1Resolver {
    function process(uint256[][] memory files, IdotnuggV1Data.Data memory data) external view returns (uint256[] memory file);
}

interface IdotnuggV1Implementer {
    function resolveBytes(uint256 tokenId, address resolver) external view returns (bytes memory res);

    function resolveRaw(uint256 tokenId, address resolver) external view returns (uint256[] memory res);

    function resolveData(uint256 tokenId, address resolver) external view returns (IdotnuggV1Data.Data memory res);

    function resolveString(uint256 tokenId, address resolver) external view returns (string memory res);

    function resolveBytesResizeable(
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (bytes memory res);

    function resolveRawResizeable(
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (uint256[] memory res);

    function resolveDataResizeable(
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (IdotnuggV1Data.Data memory res);

    function resolveStringResizeable(
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view returns (string memory res);

    function setResolver(uint256 tokenId, address to) external;

    function dotnuggV1Processer() external view returns (address);

    function resolverOf(uint256 tokenId) external view returns (address);

    function defaultWidth() external view returns (uint8);

    function defaultZoom() external view returns (uint8);
}
