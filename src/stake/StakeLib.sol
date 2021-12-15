// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../libraries/QuadMath.sol';

import '../token/Token.sol';

import './StakeShiftLib.sol';

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library StakeLib {
    using QuadMath for uint256;
    using StakeShiftLib for uint256;

    /// @param amount a parameter just like in doxygen (must be followed by parameter name)
    event StakeEth(uint256 amount);

    /// @param amount a parameter just like in doxygen (must be followed by parameter name)
    event UnStakeEth(uint256 amount);

    function addStakedSharesAndEth(
        Token.Storage storage nuggft,
        uint256 shares,
        uint256 eth
    ) internal {
        require(shares < ShiftLib.mask(64) && eth < ShiftLib.mask(192), 'SL:SS:0');

        (uint256 activeShare, uint256 activeEth) = nuggft._stake.getStakedSharesAndEth();

        nuggft._stake = nuggft._stake.setStakedShares(activeShare + shares).setStakedEth(activeEth + eth);

        emit StakeEth(eth);
    }

    function addStakedShares(Token.Storage storage nuggft, uint256 amount) internal {
        require(amount < ShiftLib.mask(64), 'SL:SS:0');

        uint256 activeShares = nuggft._stake.getStakedShares();

        nuggft._stake = nuggft._stake.setStakedShares(activeShares + amount);
    }

    function addStakedEth(Token.Storage storage nuggft, uint256 amount) internal {
        require(amount < ShiftLib.mask(192), 'SL:SS:0');

        uint256 activeEth = nuggft._stake.getStakedEth();

        nuggft._stake = nuggft._stake.setStakedEth(activeEth + amount);
        emit StakeEth(amount);
    }

    function subStakedShares(Token.Storage storage nuggft, uint256 amount) internal {
        uint256 activeShares = nuggft._stake.getStakedShares();

        require(activeShares >= amount, 'SL:SS:0');

        nuggft._stake = nuggft._stake.setStakedShares(activeShares - amount);
    }

    function subStakedEth(Token.Storage storage nuggft, uint256 amount) internal {
        uint256 activeEth = nuggft._stake.getStakedEth();

        require(activeEth >= amount, 'SL:SS:0');

        nuggft._stake = nuggft._stake.setStakedEth(activeEth - amount);

        emit UnStakeEth(amount);
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
        if (active_shares == 0) return 0;
        res = roundup ? share_amount.mulDivRoundingUp(active_eth_supply, active_shares) : share_amount.mulDiv(active_eth_supply, active_shares);
    }
}
