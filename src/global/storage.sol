// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Vault} from '../vault/storage.sol';
import {Stake} from '../stake/storage.sol';
import {Swap} from '../swap/storage.sol';
import {Proof} from '../proof/storage.sol';
import {Token} from '../token/storage.sol';
import {Loan} from '../loan/storage.sol';

library Global {
    struct Storage {
        Token.Storage token;
        Stake.Storage stake;
        Vault.Storage vault;
        Proof.Storage proof;
        Loan.Mapping loan;
        Swap.Full swap;
    }

    function ptr() internal pure returns (Storage storage s) {
        assembly {
            s.slot := 0x42069
        }
    }
}
