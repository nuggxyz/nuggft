// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../token/Token.sol';
import './StakeType.sol';

/**
 * @title StakeMath
 * @notice a library for performing staking operations
 * @dev #TODO
 */
library StakeLib {
    using QuadMath for uint256;
    using StakeType for uint256;

    event Stake()

    function addStakedSharesAndEth(
        Token.Storage storage nuggft,
        uint256 shares,
        uint256 eth
    ) internal {
        require(shares < ShiftLib.mask(64) && eth < ShiftLib.mask(192), 'SL:SS:0');

        (uint256 activeShare, uint256 activeEth) = nuggft._stake.getStakedSharesAndEth();

        nuggft._stake = nuggft._stake.setStakedShares(activeShare + shares).setStakedEth(activeEth + eth);
    }

    function addStakedShares(Token.Storage storage nuggft, uint256 amount) internal {
        require(amount < ShiftLib.mask(64), 'SL:SS:0');

        uint256 activeShares = nuggft._stake.getStakedShares();

        nuggft._stake = nuggft._stake.setStakedShares(activeShares + amount);
    }

    function subStakedShares(Token.Storage storage nuggft, uint256 amount) internal {
        uint256 activeShares = nuggft._stake.getStakedShares();

        require(activeShares >= amount, 'SL:SS:0');

        nuggft._stake = nuggft._stake.setStakedShares(activeShares - amount);
    }

    function addStakedEth(Token.Storage storage nuggft, uint256 amount) internal {
        require(amount < ShiftLib.mask(192), 'SL:SS:0');

        uint256 activeEth = nuggft._stake.getStakedEth();

        nuggft._stake = nuggft._stake.setStakedEth(activeEth + amount);
    }

    function subStakedEth(Token.Storage storage nuggft, uint256 amount) internal {
        uint256 activeEth = nuggft._stake.getStakedEth();

        require(activeEth >= amount, 'SL:SS:0');

        nuggft._stake = nuggft._stake.setStakedEth(activeEth - amount);
    }

    function getActiveEthPerShare(Token.Storage storage nuggft) internal view returns (uint256 res) {
        uint256 stake = nuggft._stake;
        res = sharesToEth(1, stake.getStakedEth(), stake.getStakedShares(), false);
    }

    function getActiveStakedShares(Token.Storage storage nuggft) internal view returns (uint256 res) {
        res = nuggft._stake.getStakedShares();
    }

    function getActiveStakedEth(Token.Storage storage nuggft) internal view returns (uint256 res) {
        res = nuggft._stake.getStakedEth();
    }

    function sharesToEth(
        uint256 share_amount,
        uint256 active_eth_supply,
        uint256 active_shares,
        bool roundup
    ) private pure returns (uint256 res) {
        res = roundup ? share_amount.mulDivRoundingUp(active_eth_supply, active_shares) : share_amount.mulDiv(active_eth_supply, active_shares);
    }
}
