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

    address public dotnuggV1Processer;

    uint8 public defaultWidth = 45;

    uint8 public defaultZoom = 10;

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

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
        uint160 safeTokenId = tokenId.safe160();

        address resolver = FileView.hasResolver(safeTokenId) ? FileView.resolverOf(safeTokenId) : dotnuggV1Processer;

        res = IdotnuggV1Processer(dotnuggV1Processer).dotnuggToString(address(this), tokenId, resolver, defaultWidth, defaultZoom);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                HELPERS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function prepareFiles(uint256 tokenId) public view override returns (uint256[][] memory input, IdotnuggV1Data.Data memory data) {
        (input, data) = FileCore.prepareForProcess(tokenId.safe160());
    }
}
