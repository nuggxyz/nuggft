// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {File} from '../file/FileStorage.sol';
import {Stake} from '../stake/StakeStorage.sol';
import {Swap} from '../swap/SwapStorage.sol';
import {Proof} from '../proof/ProofStorage.sol';
import {Token} from '../token/TokenStorage.sol';
import {Loan} from '../loan/LoanStorage.sol';

library Global {
    struct Storage {
        Token.Storage token;
        Stake.Storage stake;
        File.Storage file;
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