// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IDotNuggV1Processer {
    function process(uint256[][] memory files, bytes memory data) external view returns (uint256[] memory file);
}

interface IDotNuggV1BytesResolver {
    function resolveBytes(uint256[] memory file, bytes memory data) external view returns (bytes memory res);
}

interface IDotNuggV1RawResolver {
    function resolveRaw(uint256[] memory file, bytes memory data) external view returns (uint256[] memory res);
}

interface IDotNuggV1StringResolver {
    function resolveString(uint256[] memory file, bytes memory data) external view returns (string memory res);
}
