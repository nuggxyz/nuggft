// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../token/Token.sol';
import './StakeLib.sol';
import '../interfaces/INuggFT.sol';

abstract contract Stakeable is IStakeable {
    using StakeLib for Token.Storage;

    function totalSupply() public view override returns (uint256 res) {
        res = totalStakedShares();
    }

    function totalStakedShares() public view override returns (uint256 res) {
        res = nuggft().getActiveStakedShares();
    }

    function totalStakedEth() public view override returns (uint256 res) {
        res = nuggft().getActiveStakedEth();
    }

    function activeEthPerShare() public view override returns (uint256 res) {
        res = nuggft().getActiveEthPerShare();
    }

    function nuggft() internal view virtual returns (Token.Storage storage);
}
