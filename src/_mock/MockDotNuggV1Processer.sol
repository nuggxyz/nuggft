// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../interfaces/dotnuggv1/IDotnuggV1Processor.sol';
import '../interfaces/dotnuggv1/IDotnuggV1Data.sol';
import '../interfaces/dotnuggv1/IDotnuggV1Implementer.sol';

import '../_test/utils/Print.sol';


import {SSTORE2} from './libraries/SSTORE2.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';


abstract contract DotnuggV1Storage is IDotnuggV1Storage {
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    // Mapping from token ID to owner address
    mapping(address => mapping(uint8 => uint168[])) sstore2Pointers;
    mapping(address => mapping(uint8 => uint8)) featureLengths;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function storeFiles(uint8 feature, uint256[][] calldata data) external override returns (uint8 res) {
        uint8 len = data.length.safe8();

        require(len > 0, 'F:0');

        address ptr = SSTORE2.write(abi.encode(data));

        sstore2Pointers[msg.sender][feature].push(uint168(uint160(ptr)) | (uint168(len) << 160));

        featureLengths[msg.sender][feature] += len;

        return len;
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 GET FILES
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function getBatchFiles(address implementer, uint8[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint8 i = 0; i < ids.length; i++) {
            if (ids[i] == 0) data[i] = new uint256[](0);
            else data[i] = get(implementer, i, ids[i]);
        }
    }

    function get(
        address implementer,
        uint8 feature,
        uint8 pos
    ) internal view returns (uint256[] memory data) {
        require(pos != 0, 'F:1');

        pos--;

        uint8 totalLength = featureLengths[implementer][feature];

        require(pos < totalLength, 'F:2');

        uint168[] memory ptrs = sstore2Pointers[implementer][feature];

        address store;
        uint8 storePos;

        uint8 workingPos;

        for (uint256 i = 0; i < ptrs.length; i++) {
            uint8 here = uint8(ptrs[i] >> 160);
            if (workingPos + here > pos) {
                store = address(uint160(ptrs[i]));
                storePos = pos - workingPos;
                break;
            } else {
                workingPos += here;
            }
        }

        require(store != address(0), 'F:3');

        data = abi.decode(SSTORE2.read(address(uint160(store))), (uint256[][]))[storePos];
    }
}


contract MockdotnuggV1Processor is IDotnuggV1Processor, DotnuggV1Storage {
    function process(
        address implementer,
        uint256 tokenId,
        uint8 width
    ) public view override returns (uint256[] memory resp, IDotnuggV1Data.Data memory dat) {
        IDotnuggV1Data.Data memory data = IDotnuggV1Implementer(implementer).prepareFiles(tokenId);
        uint256[][] memory files = getBatchFiles(implementer, data.ids);
        resp = processCore(files, data, width);
        dat = data;
    }



    function processCore(
        uint256[][] memory files,
        IDotnuggV1Data.Data memory,
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
        IDotnuggV1Data.Data memory,
        uint8
    ) public pure override returns (bytes memory res) {
        res = abi.encode(file);
    }

    function resolveData(
        uint256[] memory,
        IDotnuggV1Data.Data memory data,
        uint8
    ) public pure override returns (IDotnuggV1Data.Data memory res) {
        res = data;
    }

    function resolveString(
        uint256[] memory file,
        IDotnuggV1Data.Data memory,
        uint8
    ) public pure override returns (string memory res) {
        res = string(abi.encode(file));
    }

    function resolveRaw(
        uint256[] memory file,
        IDotnuggV1Data.Data memory,
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
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        if (resolver != address(0)) {
            res = IDotnuggV1Processor(resolver).resolveRaw(res, data, zoom);
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
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        res = IDotnuggV1Processor(resolver).resolveBytes(file, data, zoom);
    }

    function dotnuggToString(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (string memory res) {
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        res = IDotnuggV1Processor(resolver).resolveString(file, data, zoom);
    }

    function dotnuggToData(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (IDotnuggV1Data.Data memory res) {
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        res = IDotnuggV1Processor(resolver).resolveData(file, data, zoom);
    }
}
