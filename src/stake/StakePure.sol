// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

library StakePure {
    /// 96 protocol
    /// 96 stakedEth
    /// 64 stakedShares

    uint96 constant PROTOCOL_FEE_BPS = 1000;

    // @test input output unit test
    function getProtocolEth(uint256 cache) internal pure returns (uint96 res) {
        // using casting to select only 96
        res = uint96(cache);
    }

    function setProtocolEth(uint256 cache, uint96 update) internal pure returns (uint256 res) {
        res = cache & ShiftLib.fullsubmask(96, 0);
        res |= update;
    }

    // @test input output unit test
    function getStakedEth(uint256 cache) internal pure returns (uint96 res) {
        // using casting to select only 96
        res = uint96(cache >> 96);
    }

    function setStakedEth(uint256 cache, uint96 update) internal pure returns (uint256 res) {
        // clear stakedEth
        res = cache & ShiftLib.fullsubmask(96, 96);
        res |= uint256(update) << 96;
    }

    // @test input output unit test
    function getStakedShares(uint256 cache) internal pure returns (uint64 res) {
        res = uint64(cache >> 192);
    }

    function setStakedShares(uint256 cache, uint64 update) internal pure returns (uint256 res) {
        res = cache & type(uint192).max;
        res |= (uint256(update) << 192);
    }

    // @test manual ish - combined input output
    function getStakedSharesAndEth(uint256 cache)
        internal
        pure
        returns (
            uint64 shares,
            uint96 eth,
            uint96 proto
        )
    {
        shares = getStakedShares(cache);
        eth = getStakedEth(cache);
        proto = getProtocolEth(cache);
    }

    // @test manual
    function getMinSharePrice(uint256 cache) internal pure returns (uint96 res) {
        res = getEthPerShare(cache);
        res += (res * (getStakedShares(cache) + PROTOCOL_FEE_BPS)) / 10000;
    }

    // @test manual
    function getEthPerShare(uint256 cache) internal pure returns (uint96 res) {
        res = getStakedShares(cache) == 0 ? 0 : getStakedEth(cache) / getStakedShares(cache);
    }
}
