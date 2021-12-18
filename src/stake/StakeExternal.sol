// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IStakeExternal} from '../interfaces/INuggFT.sol';

import {StakeView} from './StakeView.sol';
import {StakeTrust} from './StakeTrust.sol';
import {StakeCore} from './StakeCore.sol';

abstract contract StakeExternal is IStakeExternal, StakeTrust {
    function extractProtocolEth() public override requiresTrust {
        StakeCore.trustedExtractProtocolEth();
    }

    function totalStakedShares() public view override returns (uint64 res) {
        res = StakeView.getActiveStakedShares();
    }

    function totalStakedEth() public view override returns (uint96 res) {
        res = StakeView.getActiveStakedEth();
    }

    function activeEthPerShare() public view override returns (uint96 res) {
        res = StakeView.getActiveEthPerShare();
    }

    function totalProtocolEth() public view override returns (uint96 res) {
        res = StakeView.getActiveProtocolEth();
    }

    function totalSupply() public view override returns (uint256 res) {
        res = totalStakedShares();
    }
}
