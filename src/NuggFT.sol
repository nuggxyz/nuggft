// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721Metadata} from './interfaces/IERC721.sol';

import {INuggFT as a} from './interfaces/INuggFT.sol';

import {TokenExternal as ERC721} from './token/TokenExternal.sol';
import {SwapExternal as Swapable} from './swap/SwapExternal.sol';
import {ProofExternal as Provable} from './proof/ProofExternal.sol';
import {FileExternal as DotNugg} from './file/FileExternal.sol';
import {StakeExternal as Staked} from './stake/StakeExternal.sol';
import {LoanExternal as Loanable} from './loan/LoanExternal.sol';
import {EpochExternal as Epoched} from './epoch/EpochExternal.sol';
import {TrustExternal as Migratable} from './trust/TrustExternal.sol';

contract NuggFT is a, Swapable, Provable, Loanable, Migratable, Staked, Epoched, DotNugg, ERC721 {
    constructor(address _defaultResolver) DotNugg(_defaultResolver) {
        emit Genesis();
    }

    function tokenURI(uint256 tokenId) public view override(DotNugg, IERC721Metadata) returns (string memory) {
        return DotNugg.tokenURI(tokenId);
    }

    function name() public pure override returns (string memory) {
        return 'Nugg Fungible Token V1';
    }

    function symbol() public pure override returns (string memory) {
        return 'NUGGFT';
    }
}
