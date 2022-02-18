// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {ShiftLib} from './ShiftLib.sol';

library NuggftV1StakeType {
    /// 96 protocol
    /// 96 stakedEth
    /// 64 stakedShares

    function proto(uint256 cache) internal pure returns (uint96 res) {
        res = uint96(cache);
    }

    function proto(uint256 cache, uint96 update) internal pure returns (uint256 res) {
        res = cache & ShiftLib.imask(96, 0);
        res |= update;
    }

    function addProto(uint256 cache, uint96 add) internal pure returns (uint256 res) {
        unchecked {
            add += proto(cache);
            res = proto(cache, add);
        }
    }

    function subProto(uint256 cache, uint96 sub) internal pure returns (uint256 res) {
        sub = proto(cache) - sub;
        res = proto(cache, sub);
    }

    // @test input output unit test
    function staked(uint256 cache) internal pure returns (uint96 res) {
        // using casting to select only 96
        res = uint96(cache >> 96);
    }

    function staked(uint256 cache, uint96 update) internal pure returns (uint256 res) {
        // clear stakedEth
        res = cache & ShiftLib.imask(96, 96);
        res |= uint256(update) << 96;
    }

    function addStaked(uint256 cache, uint96 add) internal pure returns (uint256 res) {
        unchecked {
            // maybe oot
            add += staked(cache);
            res = staked(cache, add);
        }
    }

    function subStaked(uint256 cache, uint96 sub) internal pure returns (uint256 res) {
        unchecked {
            sub = staked(cache) - sub;
            res = staked(cache, sub);
        }
    }

    // @test input output unit test
    function shares(uint256 cache) internal pure returns (uint64 res) {
        res = uint64(cache >> 192);
    }

    function addShares(uint256 cache, uint64 add) internal pure returns (uint256 res) {
        unchecked {
            add += shares(cache);
            res = shares(cache, add);
        }
    }

    function subShares(uint256 cache, uint64 sub) internal pure returns (uint256 res) {
        unchecked {
            sub = shares(cache) - sub;
            res = shares(cache, sub);
        }
    }

    function shares(uint256 cache, uint64 update) internal pure returns (uint256 res) {
        res = cache & type(uint192).max;
        res |= (uint256(update) << 192);
    }
}
