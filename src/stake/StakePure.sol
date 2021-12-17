// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

library StakePure {
    function getEthPerShare(uint256 state) internal pure returns (uint192 res) {
        res = getStakedShares(state) == 0 ? 0 : getStakedEth(state) / getStakedShares(state);
    }

    function getStakedEth(uint256 state) internal pure returns (uint192 res) {
        res = uint192(state & ShiftLib.mask(192));
    }

    function setStakedEth(uint256 state, uint192 update) internal pure returns (uint256 res) {
        res = state & (ShiftLib.mask(64) << 192);
        res |= update;
    }

    function getStakedShares(uint256 state) internal pure returns (uint64 res) {
        res = uint64(state >> 192);
    }

    function setStakedShares(uint256 state, uint64 update) internal pure returns (uint256 res) {
        res = state & ShiftLib.mask(192);
        res |= (uint256(update) << 192);
    }

    function getStakedSharesAndEth(uint256 state) internal pure returns (uint64 shares, uint192 eth) {
        shares = getStakedShares(state);
        eth = getStakedEth(state);
    }
}
