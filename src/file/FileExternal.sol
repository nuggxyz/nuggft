// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IFileExternal, INuggFT} from '../interfaces/INuggFT.sol';

import {IdotnuggV1Processer} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Resolver} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Data} from '../interfaces/IdotnuggV1.sol';
import {SSTORE2} from '../libraries/SSTORE2.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {FileCore} from './FileCore.sol';
import {FilePure} from './FilePure.sol';

import {FileView} from './FileView.sol';
import {File} from './FileStorage.sol';

contract FileExternal is IFileExternal {
    using SafeCastLib for uint256;

    address public nuggft;

    address public immutable override dotnuggV1Processer;

    uint8 public immutable override defaultWidth = 45;

    uint8 public immutable override defaultZoom = 10;

    constructor(address _dotnuggV1Processer) {
        require(_dotnuggV1Processer != address(0));
        dotnuggV1Processer = _dotnuggV1Processer;
        nuggft = msg.sender;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            RESOLVER MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function setResolver(uint256 tokenId, address to) public virtual override {
        FileCore.setResolver(tokenId.safe160(), to);
    }

    function resolverOf(uint256 tokenId) public view virtual override returns (address) {
        return FileView.resolverOf(tokenId.safe160());
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            MAIN FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function resolveRaw(uint256 tokenId, address resolver) public view override returns (uint256[] memory res) {
        res = resolveRawResizeable(tokenId, resolver, defaultWidth, defaultZoom);
    }

    function resolveBytes(uint256 tokenId, address resolver) public view override returns (bytes memory res) {
        res = resolveBytesResizeable(tokenId, resolver, defaultWidth, defaultZoom);
    }

    function resolveString(uint256 tokenId, address resolver) public view override returns (string memory res) {
        res = resolveStringResizeable(tokenId, resolver, defaultWidth, defaultZoom);
    }

    function resolveData(uint256 tokenId, address resolver) public view override returns (IdotnuggV1Data.Data memory res) {
        res = resolveDataResizeable(tokenId, resolver, defaultWidth, defaultZoom);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        MAIN FUNCTIONS - RESIZABLE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function resolveRawResizeable(
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (uint256[] memory res) {
        (uint256[] memory file, , IdotnuggV1Data.Data memory data) = processTokenId(tokenId, width, zoom);

        if (resolver != address(0)) {
            res = IdotnuggV1Processer(resolver).resolveRaw(res, data);
        } else {
            res = file;
        }
    }

    function resolveBytesResizeable(
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (bytes memory res) {
        (uint256[] memory file, , IdotnuggV1Data.Data memory data) = processTokenId(tokenId, width, zoom);

        res = IdotnuggV1Processer(resolver).resolveBytes(file, data);
    }

    function resolveStringResizeable(
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (string memory res) {
        (uint256[] memory file, , IdotnuggV1Data.Data memory data) = processTokenId(tokenId, width, zoom);

        res = IdotnuggV1Processer(resolver).resolveString(file, data);
    }

    function resolveDataResizeable(
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) public view override returns (IdotnuggV1Data.Data memory res) {
        (uint256[] memory file, , IdotnuggV1Data.Data memory data) = processTokenId(tokenId, width, zoom);

        res = IdotnuggV1Processer(resolver).resolveData(file, data);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            RESOLVE TO DEFAULT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function resolveRaw(uint160 tokenId) public view returns (uint256[] memory res) {
        if (FileView.hasResolver(tokenId)) {
            res = resolveRaw(tokenId, FileView.resolverOf(tokenId));
        } else {
            res = resolveRaw(tokenId, address(0));
        }
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory res) {
        uint160 safeTokenId = tokenId.safe160();

        if (FileView.hasResolver(safeTokenId)) {
            res = resolveString(safeTokenId, FileView.resolverOf(safeTokenId));
        } else {
            res = resolveString(safeTokenId, dotnuggV1Processer);
        }
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                HELPERS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function processTokenId(
        uint256 tokenId,
        uint8 width,
        uint8 zoom
    )
        internal
        view
        returns (
            uint256[] memory res,
            uint256[][] memory input,
            IdotnuggV1Data.Data memory data
        )
    {
        (input, data) = FileCore.prepareForProcess(tokenId.safe160(), width, zoom);

        res = IdotnuggV1Processer(dotnuggV1Processer).process(input, data);
    }

    function prepareForProcess(
        uint160 tokenId,
        uint8 zoom,
        uint8 size
    ) internal view returns (uint256[][] memory files, IdotnuggV1Data.Data memory data) {
        (uint256 proof, uint8[] memory ids, uint8[] memory extras, uint8[] memory xovers, uint8[] memory yovers) = INuggFT(nuggft)
            .parsedProofOf(tokenId);

        files = FileCore.getBatchFiles(ids);

        data = IdotnuggV1Data.Data({
            version: 1,
            zoom: zoom,
            size: size,
            renderedAt: block.timestamp,
            name: 'NuggFT V1',
            desc: 'Nugg Fungible Token V1 by nugg.xyz',
            owner: INuggFT(nuggft).ownerOf(tokenId),
            tokenId: tokenId,
            proof: proof,
            ids: ids,
            extras: extras,
            xovers: xovers,
            yovers: yovers
        });
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function trustedStoreFiles(
        uint8 feature,
        uint256[][] calldata data
    ) internal {
        // require(trust._isTrusted, 'T:0');

        uint8 len = data.length.safe8();

        require(len > 0, 'VC:0');

        uint168 working = uint168(len) << 160;

        address ptr = SSTORE2.write(abi.encode(data));

        File.spointer().ptrs[feature].push(uint168(uint160(ptr)) | working);

        uint256 cache = File.spointer().lengthData;

        uint8[] memory lengths = FilePure.getLengths(cache);

        lengths[feature] += len;

        File.spointer().lengthData = FilePure.setLengths(cache, lengths);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 GET FILES
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function getBatchFiles(uint8[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint8 i = 0; i < ids.length; i++) {
            if (ids[i] == 0) data[i] = new uint256[](0);
            else data[i] = get(i, ids[i]);
        }
    }

    function get(uint8 feature, uint8 pos) internal view returns (uint256[] memory data) {
        require(pos != 0, 'VC:2');

        pos--;

        uint8 totalLength = FilePure.getLengths(File.spointer().lengthData)[feature];

        require(pos < totalLength, 'VC:1');

        uint168[] memory ptrs = File.spointer().ptrs[feature];

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

        require(store != address(0), 'VC:2');

        data = abi.decode(SSTORE2.read(address(uint160(store))), (uint256[][]))[storePos];
    }
}
