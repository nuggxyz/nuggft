// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IFileExternal} from '../interfaces/INuggFT.sol';

import {IDotNuggV1Processer} from '../interfaces/IDotNuggV1.sol';
import {IDotNuggV1BytesResolver} from '../interfaces/IDotNuggV1.sol';
import {IDotNuggV1RawResolver} from '../interfaces/IDotNuggV1.sol';
import {IDotNuggV1StringResolver} from '../interfaces/IDotNuggV1.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {FileCore} from './FileCore.sol';
import {FileView} from './FileView.sol';
import {File} from './FileStorage.sol';

abstract contract FileExternal is IFileExternal {
    using SafeCastLib for uint256;

    address public immutable dotnuggV1Processer;

    constructor(address _dotnuggV1Processer) {
        require(_dotnuggV1Processer != address(0));
        dotnuggV1Processer = _dotnuggV1Processer;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            RESOLVER MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function setResolver(uint160 tokenId, address to) public virtual override {
        FileCore.setResolver(tokenId, to);
    }

    function resolverOf(uint160 tokenId) public view virtual override returns (address) {
        return FileView.resolverOf(tokenId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            MAIN FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function resolveRaw(uint160 tokenId, address resolver) public view returns (uint256[] memory res) {
        (uint256[] memory file, , bytes memory data) = processTokenId(tokenId);

        if (resolver != address(0)) {
            res = IDotNuggV1RawResolver(resolver).resolveRaw(res, data);
        } else {
            res = file;
        }
    }

    function resolveBytes(uint160 tokenId, address resolver) public view returns (bytes memory res) {
        (uint256[] memory file, , bytes memory data) = processTokenId(tokenId);

        res = IDotNuggV1BytesResolver(resolver).resolveBytes(file, data);
    }

    function resolveString(uint160 tokenId, address resolver) public view returns (string memory res) {
        (uint256[] memory file, , bytes memory data) = processTokenId(tokenId);

        res = IDotNuggV1StringResolver(resolver).resolveString(file, data);
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

    function processTokenId(uint160 tokenId)
        internal
        view
        returns (
            uint256[] memory res,
            uint256[][] memory input,
            bytes memory data
        )
    {
        (input, data) = FileCore.prepareForProcess(tokenId);

        res = IDotNuggV1Processer(dotnuggV1Processer).process(input, data);
    }
}
