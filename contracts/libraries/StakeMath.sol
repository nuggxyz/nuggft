// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import './QuadMath.sol';

import 'hardhat/console.sol';

/**
 * @title StakeMath
 * @notice a library for performing staking operations
 * @dev #TODO
 */
library StakeMath {
    using QuadMath for uint256;

    struct Position {
        uint256 rOwned;
    }

    struct State {
        uint256 tSupply;
        uint256 rSupply;
    }

    /**
     * @notice #TODO
     * @param state the percent out of 100 to be taken
     * @param pos the percent out of 100 to be taken
     * @return res shares
     * @dev #TODO
     */
    function getBalance(State memory state, Position memory pos) internal pure returns (uint256 res) {
        return pos.rOwned > 0 ? _safeRtoT(state, pos.rOwned) : 0;
    }

    /**
     * @notice #TODO
     * @param state the percent out of 100 to be taken
     * @param pos the percent out of 100 to be taken
     * @return res shares
     * @dev #TODO
     */
    function getOwnershipX128(State memory state, Position memory pos) internal pure returns (uint256 res) {
        return pos.rOwned.mulDiv(QuadMath._BINARY128, state.rSupply);
    }

    function _safeRtoT(State memory state, uint256 rAmount) private pure returns (uint256) {
        return rAmount.mulDiv(state.tSupply, state.rSupply);
    }

    function _safeTtoR(State memory state, uint256 tAmount) private pure returns (uint256) {
        return tAmount.mulDiv(state.rSupply, state.tSupply);
    }

    function _safeRtoTRoundingUp(State memory state, uint256 rAmount) private pure returns (uint256) {
        return rAmount.mulDivRoundingUp(state.tSupply, state.rSupply);
    }

    function _safeTtoRRoundingUp(State memory state, uint256 tAmount) private pure returns (uint256) {
        return tAmount.mulDivRoundingUp(state.rSupply, state.tSupply);
    }

    function applyShareIncrease(
        State memory state,
        Position memory pos,
        uint256 tAmount
    ) internal pure {
        if (state.rSupply == 0 && state.tSupply == 0) {
            pos.rOwned = tAmount;
            state.rSupply = tAmount;
            state.tSupply = tAmount;
        } else {
            uint256 amountR = _safeTtoR(state, tAmount);
            pos.rOwned += amountR;
            state.rSupply += amountR;
            state.tSupply += tAmount;
        }
    }

    function applyShareDecrease(
        State memory state,
        Position memory pos,
        uint256 tAmount
    ) internal pure {
        uint256 amountR = _safeTtoRRoundingUp(state, tAmount);
        pos.rOwned -= amountR;
        state.rSupply -= amountR;
        state.tSupply -= tAmount;
    }

    function applyRewardIncrease(State memory state, uint256 amount) internal pure {
        state.tSupply += amount;
    }
}
