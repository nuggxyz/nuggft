// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {StakeView} from './view.sol';

import {IStakeExternal} from '../interfaces/INuggFT.sol';

abstract contract StakeExternal is IStakeExternal {
    function totalStakedShares() public view override returns (uint256 res) {
        res = StakeView.getActiveStakedShares();
    }

    function totalStakedEth() public view override returns (uint256 res) {
        res = StakeView.getActiveStakedEth();
    }

    function activeEthPerShare() public view override returns (uint256 res) {
        res = StakeView.getActiveEthPerShare();
    }

    function totalSupply() public view override returns (uint256 res) {
        res = totalStakedShares();
    }
}
