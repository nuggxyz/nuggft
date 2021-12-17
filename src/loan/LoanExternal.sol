// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ILoanExternal} from '../interfaces/INuggFT.sol';

import {LoanCore} from './LoanCore.sol';

abstract contract LoanExternal is ILoanExternal {
    function loan(uint256 tokenId) external override {
        LoanCore.loan(tokenId);
    }

    function payoff(uint256 tokenId) external payable override {
        LoanCore.payoff(tokenId);
    }

    function liqidate(uint256 tokenId) external payable override {
        LoanCore.liquidate(tokenId);
    }

    function payoffAmount() external view override returns (uint256 res) {
        res = LoanCore.payoffAmount();
    }
}
