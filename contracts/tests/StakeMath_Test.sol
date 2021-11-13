// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '../libraries/StakeMath.sol';

contract StakeMath_Test {
    function getBalance(StakeMath.State memory state, StakeMath.Position memory pos) external pure returns (uint256 res) {
        res = StakeMath.getBalance(state, pos);
    }

    function getOwnershipX128(StakeMath.State memory state, StakeMath.Position memory pos) external pure returns (uint256 res) {
        res = StakeMath.getOwnershipX128(state, pos);
    }

    function applyShareIncrease(
        StakeMath.State memory state,
        StakeMath.Position memory pos,
        uint256 tAmount
    ) external pure returns (StakeMath.State memory, StakeMath.Position memory) {
        StakeMath.applyShareIncrease(state, pos, tAmount);
        // console.log(state.tSupply, state.rSupply, pos.rOwned);
        return (state, pos);
    }

    function applyShareDecrease(
        StakeMath.State memory state,
        StakeMath.Position memory pos,
        uint256 tAmount
    ) external pure returns (StakeMath.State memory, StakeMath.Position memory) {
        StakeMath.applyShareDecrease(state, pos, tAmount);
        return (state, pos);
    }

    function applyRewardIncrease(StakeMath.State memory state, uint256 amount) external pure returns (StakeMath.State memory) {
        StakeMath.applyRewardIncrease(state, amount);
        return (state);
    }
}
