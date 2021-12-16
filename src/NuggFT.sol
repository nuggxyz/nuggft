// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721Metadata} from './interfaces/IERC721.sol';

import {INuggFT as a} from './interfaces/INuggFT.sol';

import {TokenExternal as Token} from './token/external.sol';
import {SwapExternal as Swapable} from './swap/external.sol';
import {ProofExternal as Provable} from './proof/external.sol';
import {VaultExternal as Vault} from './vault/external.sol';
import {StakeExternal as Staked} from './stake/external.sol';
import {LoanExternal as Loanable} from './loan/external.sol';
import {EpochExternal as Epoched} from './epoch/external.sol';

contract NuggFT is a, Swapable, Provable, Loanable, Staked, Epoched, Vault, Token {
    constructor(address _defaultResolver) Token('NUGGFT', 'Nugg Fungible Token') Vault(_defaultResolver) {
        emit Genesis();
    }

    function tokenURI(uint256 tokenId) public view override(IERC721Metadata, Vault, Token) returns (string memory) {
        return Vault.tokenURI(tokenId);
    }
}
