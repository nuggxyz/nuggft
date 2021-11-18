// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import './QuadMath.sol';

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

    function decodeState(uint256 state) internal pure returns (State memory res) {
        res.tSupply = state >> 128;
        res.rSupply = (state << 128) >> 128;
    }

    function encodeState(State memory state) internal pure returns (uint256 res) {
        res = (state.tSupply << 128) | state.rSupply;
    }

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

    function applyShareAdd(
        State memory state,
        Position memory pos,
        uint256 tAmount
    ) internal pure returns (uint256 amountR) {
        if (state.rSupply == 0 && state.tSupply == 0) {
            amountR = tAmount;
            pos.rOwned = amountR;
            state.rSupply = amountR;
            state.tSupply = tAmount;
        } else {
            amountR = _safeTtoR(state, tAmount);
            pos.rOwned += amountR;
            state.rSupply += amountR;
            state.tSupply += tAmount;
        }
    }

    function applyShareSub(
        State memory state,
        Position memory pos,
        uint256 tAmount
    ) internal pure returns (uint256 amountR) {
        amountR = _safeTtoRRoundingUp(state, tAmount);
        pos.rOwned -= amountR;
        state.rSupply -= amountR;
        state.tSupply -= tAmount;
    }

    function applyShareMove(
        State memory state,
        Position memory posFrom,
        Position memory posTo,
        uint256 tAmount
    ) internal pure returns (uint256 amountR) {
        amountR = _safeTtoRRoundingUp(state, tAmount);
        posFrom.rOwned -= amountR;
        posTo.rOwned += amountR;
    }

    function applyValueAdd(State memory state, uint256 amount) internal pure {
        state.tSupply += amount;
    }
}
