// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../interfaces/IdotnuggV1.sol';
import '../_test/utils/Print.sol';

contract MockdotnuggV1Processor is IdotnuggV1Processor {
    function process(
        address implementer,
        uint256 tokenId,
        uint8 width
    ) public view override returns (uint256[] memory resp, IdotnuggV1Data.Data memory dat) {
        (uint256[][] memory files, IdotnuggV1Data.Data memory data) = IdotnuggV1Implementer(implementer).prepareFiles(tokenId);

        resp = processCore(files, data, width);
        dat = data;
    }

    function processCore(
        uint256[][] memory files,
        IdotnuggV1Data.Data memory,
        uint8 width
    ) public view returns (uint256[] memory file) {
        Print.log(width, 'width');

        for (uint256 i = 0; i < files.length; i++) {
            Print.log(files[i], 'files[i]');
        }
        return files[0];
    }

    function resolveBytes(
        uint256[] memory file,
        IdotnuggV1Data.Data memory,
        uint8
    ) public pure override returns (bytes memory res) {
        res = abi.encode(file);
    }

    function resolveData(
        uint256[] memory,
        IdotnuggV1Data.Data memory data,
        uint8
    ) public pure override returns (IdotnuggV1Data.Data memory res) {
        res = data;
    }

    function resolveString(
        uint256[] memory file,
        IdotnuggV1Data.Data memory,
        uint8
    ) public pure override returns (string memory res) {
        res = string(abi.encode(file));
    }

    function resolveRaw(
        uint256[] memory file,
        IdotnuggV1Data.Data memory,
        uint8
    ) public pure override returns (uint256[] memory res) {
        res = file;
    }

    function dotnuggToRaw(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (uint256[] memory res) {
        (uint256[] memory file, IdotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        if (resolver != address(0)) {
            res = IdotnuggV1Processor(resolver).resolveRaw(res, data, zoom);
        } else {
            res = file;
        }
    }

    function dotnuggToBytes(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (bytes memory res) {
        (uint256[] memory file, IdotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        res = IdotnuggV1Processor(resolver).resolveBytes(file, data, zoom);
    }

    function dotnuggToString(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (string memory res) {
        (uint256[] memory file, IdotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        res = IdotnuggV1Processor(resolver).resolveString(file, data, zoom);
    }

    function dotnuggToData(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (IdotnuggV1Data.Data memory res) {
        (uint256[] memory file, IdotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        res = IdotnuggV1Processor(resolver).resolveData(file, data, zoom);
    }
}
