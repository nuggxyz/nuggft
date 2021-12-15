// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../libraries/ShiftLib.sol';

library StakeShiftLib {
    function getStakedEth(uint256 state) internal pure returns (uint256 res) {
        res = state & ShiftLib.mask(192);
    }

    function setStakedShares(uint256 state, uint256 update) internal pure returns (uint256 res) {
        res = state & ShiftLib.mask(192);
        res |= (update << 192);
    }

    function setStakedEth(uint256 state, uint256 update) internal pure returns (uint256 res) {
        res = state & (ShiftLib.mask(64) << 192);
        res |= update;
    }

    function getStakedShares(uint256 state) internal pure returns (uint256 res) {
        res = state >> 192;
    }

    function getStakedSharesAndEth(uint256 state) internal pure returns (uint256 shares, uint256 eth) {
        shares = getStakedShares(state);
        eth = getStakedEth(eth);
    }
}
