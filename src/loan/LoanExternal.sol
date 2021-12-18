// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ILoanExternal} from '../interfaces/INuggFT.sol';

import {LoanCore} from './LoanCore.sol';

abstract contract LoanExternal is ILoanExternal {
    function loan(uint160 tokenId) external override {
        LoanCore.loan(tokenId);
    }

    function payoff(uint160 tokenId) external payable override {
        LoanCore.payoff(tokenId);
    }

    function rebalance(uint160 tokenId) external payable override {
        LoanCore.rebalance(tokenId);
    }
}
