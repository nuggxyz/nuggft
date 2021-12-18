// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721Metadata} from './interfaces/IERC721.sol';

import {INuggFT as a} from './interfaces/INuggFT.sol';

import {TokenExternal as Token} from './token/TokenExternal.sol';
import {SwapExternal as Swapable} from './swap/SwapExternal.sol';
import {ProofExternal as Provable} from './proof/ProofExternal.sol';
import {VaultExternal as Vault} from './vault/VaultExternal.sol';
import {StakeExternal as Staked} from './stake/StakeExternal.sol';
import {LoanExternal as Loanable} from './loan/LoanExternal.sol';
import {EpochExternal as Epoched} from './epoch/EpochExternal.sol';
import {EpochExternal as Epoched} from './epoch/EpochExternal.sol';

contract NuggFT is a, Swapable, Provable, Loanable, Staked, Epoched, Vault, Token {
    constructor(address _defaultResolver) Token('nuggft', 'Nugg Fungible Token') Vault(_defaultResolver) {
        emit Genesis();
    }

    function tokenURI(uint256 tokenId) public view override(IERC721Metadata, Vault, Token) returns (string memory) {
        return Vault.tokenURI(tokenId);
    }
}
