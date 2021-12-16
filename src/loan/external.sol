// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ILoanExternal} from '../interfaces/INuggFT.sol';

import {LoanLogic} from './logic.sol';

abstract contract LoanExternal is ILoanExternal {
    function loan(uint256 tokenId) external override {
        LoanLogic.loan(tokenId);
    }

    function payoff(uint256 tokenId) external payable override {
        LoanLogic.payoff(tokenId);
    }

    function liqidate(uint256 tokenId) external payable override {
        LoanLogic.liquidate(tokenId);
    }

    function payoffAmount() external view override returns (uint256 res) {
        res = LoanLogic.payoffAmount();
    }
}
