// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggFT as a} from './interfaces/INuggFT.sol';

import {TokenExternal as Token} from './token/external.sol';
import {SwapExternal as Swapable} from './swap/external.sol';
import {ProofExternal as Provable} from './proof/external.sol';
import {VaultExternal as Vault} from './vault/external.sol';
import {StakeExternal as Stakeable} from './stake/external.sol';
import {LoanExternal as Loanable} from './vault/external.sol';

contract NuggFT is a, Swapable, Provable, Stakeable, Loanable, Vault, Token {
    address public immutable override defaultResolver;

    uint256 internal immutable _genesis;

    constructor(address _defaultResolver) Token('NUGGFT', 'Nugg Fungible Token') {
        defaultResolver = _defaultResolver;

        emit Genesis();
    }
}
