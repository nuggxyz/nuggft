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

    function calculateProtocolFeeOf(uint96 any) internal pure returns (uint96 res) {
        res = (any * StakePure.PROTOCOL_FEE_BPS) / 10000;
    }

    // @test manual
    function minSharePriceBreakdown(uint256 cache)
        internal
        pure
        returns (
            uint96 total,
            uint96 ethPerShare,
            uint96 protocolFee,
            uint96 premium
        )
    {
        ethPerShare = getEthPerShare(cache);

        protocolFee = calculateProtocolFeeOf(ethPerShare);

        premium = ((ethPerShare * getStakedShares(cache)) / 10000);

        // require(uint256(premium) * uint256(premium) <= type(uint96).max, 'poo');

        // premium += (((ethPerShare) * 9000) / 10000);

        total = ethPerShare + protocolFee + premium;
    }

    // @test manual
    function getEthPerShare(uint256 cache) internal pure returns (uint96 res) {
        res = getStakedShares(cache) == 0 ? 0 : getStakedEth(cache) / getStakedShares(cache);
    }
}

// .388462191424698825
// .179595585120778917
//9.744857104519532829
// .683870949775377181
// .117875552479567856
//6.249897262135775214
//3.665748059134461014
//1.321523995093297549

//1.321523995093297549
//5.363510699612383365
// .117875552479567856
// .188600883967308569
