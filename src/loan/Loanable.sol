// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../token/Token.sol';
import './Loan.sol';
import '../interfaces/INuggFT.sol';

abstract contract Loanable is ILoanable {
    using StakeLib for Token.Storage;

    function payoffAmount() external view override returns (uint256 res) {
        res = Loan.payoffAmount(nuggft());
    }

    function loan(uint256 tokenId) external override {
        Loan.loan(nuggft(), genesis(), tokenId);
    }

    function payoff(uint256 tokenId) external payable override {
        Loan.payoff(nuggft(), genesis(), tokenId);
    }

    function liqidate(uint256 tokenId) external payable override {
        Loan.liquidate(nuggft(), genesis(), tokenId);
    }

    function nuggft() internal view virtual returns (Token.Storage storage);

    function genesis() public view virtual returns (uint256 res);
}
