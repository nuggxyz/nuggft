// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../../interfaces/dotnuggv1/IDotnuggV1.sol';
import '../../interfaces/dotnuggv1/IDotnuggV1Metadata.sol';
import '../../interfaces/dotnuggv1/IDotnuggV1Implementer.sol';

import {SafeCastLib} from '../../libraries/SafeCastLib.sol';

import '../utils/logger.sol';


library SSTORE2 {
    uint256 internal constant DATA_OFFSET = 1;

    function write(bytes memory data) internal returns (address pointer) {
        bytes memory runtimeCode = abi.encodePacked(hex'00', data);

        bytes memory creationCode = abi.encodePacked(hex'63', uint32(runtimeCode.length), hex'80_60_0E_60_00_39_60_00_F3', runtimeCode);

        assembly {
            pointer := create(0, add(creationCode, 32), mload(creationCode))
        }

        require(pointer != address(0), 'DEPLOYMENT_FAILED');
    }

    function read(address pointer) internal view returns (bytes memory) {
        return readBytecode(pointer, DATA_OFFSET, pointer.code.length - DATA_OFFSET);
    }

    function read(address pointer, uint256 start) internal view returns (bytes memory) {
        start += DATA_OFFSET;

        return readBytecode(pointer, start, pointer.code.length - start);
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory) {
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        require(pointer.code.length >= end, 'OUT_OF_BOUNDS');

        return readBytecode(pointer, start, end - start);
    }

    function readBytecode(
        address pointer,
        uint256 start,
        uint256 size
    ) private view returns (bytes memory data) {
        assembly {
            data := mload(0x40)
            mstore(0x40, add(data, and(add(add(size, add(start, 0x20)), 0x1f), not(0x1f))))
            mstore(data, size)
            extcodecopy(pointer, add(data, 0x20), start, size)
        }
    }
}

abstract contract DotnuggV1Storage is IDotnuggV1Storage {
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    // Mapping from token ID to owner address
    mapping(address => mapping(uint8 => uint168[])) sstore2Pointers;
    mapping(address => mapping(uint8 => uint8)) featureLengths;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function unsafeBulkStore(uint256[][][] calldata data) external override {}

    function store(uint8 feature, uint256[][] calldata data) external override returns (uint8 res) {
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

        address str;
        uint8 storePos;

        uint8 workingPos;

        for (uint256 i = 0; i < ptrs.length; i++) {
            uint8 here = uint8(ptrs[i] >> 160);
            if (workingPos + here > pos) {
                str = address(uint160(ptrs[i]));
                storePos = pos - workingPos;
                break;
            } else {
                workingPos += here;
            }
        }

        require(str != address(0), 'F:3');

        data = abi.decode(SSTORE2.read(str), (uint256[][]))[storePos];
    }
}

contract MockDotnuggV1 is IDotnuggV1, DotnuggV1Storage {
    function process(
        address implementer,
        uint256 tokenId,
        uint8 width
    ) public view override returns (uint256[] memory resp, IDotnuggV1Metadata.Memory memory dat) {
        IDotnuggV1Metadata.Memory memory data = IDotnuggV1Implementer(implementer).dotnuggV1Callback(tokenId);
        uint256[][] memory files = getBatchFiles(implementer, data.ids);
        resp = processCore(files, data, width);
        dat = data;
    }

    function stored(address implementer, uint8 feature) public view override returns (uint8 res) {
        return featureLengths[implementer][feature];
    }

    function processCore(
        uint256[][] memory files,
        IDotnuggV1Metadata.Memory memory,
        uint8 width
    ) public view returns (uint256[] memory file) {
        logger.log(width, 'width');

        for (uint256 i = 0; i < files.length; i++) {
            logger.log(files[i], 'files[i]');
        }
        return files[0];
    }

    function resolveBytes(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory,
        uint8
    ) public pure override returns (bytes memory res) {
        res = abi.encode(file);
    }

    function resolveMetadata(
        uint256[] memory,
        IDotnuggV1Metadata.Memory memory data,
        uint8
    ) public pure override returns (IDotnuggV1Metadata.Memory memory res) {
        res = data;
    }

    function resolveString(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory,
        uint8
    ) public pure override returns (string memory res) {
        res = string(abi.encode(file));
    }

    function resolveUri(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory,
        uint8
    ) public pure override returns (string memory res) {
        res = string(abi.encode(file));
    }

    function resolveRaw(
        uint256[] memory file,
        IDotnuggV1Metadata.Memory memory,
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
    ) public view override returns (address resolvedBy, uint256[] memory res) {
        (uint256[] memory file, IDotnuggV1Metadata.Memory memory data) = process(implementer, tokenId, width);

        if (resolver != address(0)) {
            res = IDotnuggV1(resolver).resolveRaw(res, data, zoom);
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
    ) public view override returns (address resolvedBy, bytes memory res) {
        (uint256[] memory file, IDotnuggV1Metadata.Memory memory data) = process(implementer, tokenId, width);

        res = IDotnuggV1(resolver).resolveBytes(file, data, zoom);
    }

    function dotnuggToString(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (address resolvedBy, string memory res) {
        (uint256[] memory file, IDotnuggV1Metadata.Memory memory data) = process(implementer, tokenId, width);

        res = IDotnuggV1(resolver).resolveString(file, data, zoom);
    }

    function dotnuggToUri(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (address resolvedBy, string memory res) {
        (uint256[] memory file, IDotnuggV1Metadata.Memory memory data) = process(implementer, tokenId, width);

        res = IDotnuggV1(resolver).resolveString(file, data, zoom);
    }

    function dotnuggToMetadata(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (address resolvedBy, IDotnuggV1Metadata.Memory memory res) {
        (uint256[] memory file, IDotnuggV1Metadata.Memory memory data) = process(implementer, tokenId, width);

        res = IDotnuggV1(resolver).resolveMetadata(file, data, zoom);
    }
}