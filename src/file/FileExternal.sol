// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IFileExternal} from '../interfaces/INuggFT.sol';

import {IdotnuggV1Processer} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Resolver} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Data} from '../interfaces/IdotnuggV1.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {FileCore} from './FileCore.sol';
import {FileView} from './FileView.sol';
import {File} from './FileStorage.sol';

abstract contract FileExternal is IFileExternal {
    using SafeCastLib for uint256;

    address public immutable override dotnuggV1Processer;

    uint8 public immutable override defaultWidth = 45;

    uint8 public immutable override defaultZoom = 10;

    constructor(address _dotnuggV1Processer) {
        require(_dotnuggV1Processer != address(0));
        dotnuggV1Processer = _dotnuggV1Processer;
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
}
