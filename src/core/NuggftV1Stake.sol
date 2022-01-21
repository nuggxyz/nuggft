// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggftV1Proof} from './NuggftV1Proof.sol';

import {INuggftV1Migrator} from '../interfaces/nuggftv1/INuggftV1Migrator.sol';
import {INuggftV1Stake} from '../interfaces/nuggftv1/INuggftV1Stake.sol';

import {CastLib} from '../libraries/CastLib.sol';
import {TransferLib} from '../libraries/TransferLib.sol';

import {NuggftV1StakeType} from '../types/NuggftV1StakeType.sol';

abstract contract NuggftV1Stake is INuggftV1Stake, NuggftV1Proof {
    using CastLib for uint256;
    using NuggftV1StakeType for uint256;

    address public migrator;

    uint256 internal stake;

    uint96 constant PROTOCOL_FEE_BPS = 1000;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc INuggftV1Stake
    function extractProtocolEth() external requiresTrust {
        uint256 cache = stake;

        TransferLib.give(msg.sender, cache.proto());

        cache = cache.proto(0);

        emit Stake(bytes32(cache));
    }

    /// @inheritdoc INuggftV1Stake
    function setMigrator(address _migrator) external requiresTrust {
        migrator = _migrator;

        emit MigratorV1Updated(_migrator);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc INuggftV1Stake
    function eps() public view override returns (uint96 res) {
        assembly {
            let cache := sload(stake.slot)
            res := shr(192, cache)
            res := div(and(shr(96, cache), sub(shl(96, 1), 1)), res)
        }
    }

    /// @inheritdoc INuggftV1Stake
    function msp() public view override returns (uint96 res) {
        (res, , , ) = minSharePriceBreakdown(stake);
    }

    // / @inheritdoc INuggftV1Stake
    function shares() public view override returns (uint64 res) {
        res = stake.shares();
    }

    /// @inheritdoc INuggftV1Stake
    function staked() public view override returns (uint96 res) {
        res = stake.staked();
    }

    /// @inheritdoc INuggftV1Stake
    function proto() public view override returns (uint96 res) {
        res = stake.proto();
    }

    /// @inheritdoc INuggftV1Stake
    function totalSupply() public view override returns (uint256 res) {
        res = shares();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                   adders
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @notice handles the adding of shares - ensures enough eth is being added
    /// @dev this is the only way to add shares - the logic here ensures that "ethPerShare" can never decrease
    function addStakedShareFromMsgValue() internal {
        uint256 cache;

        assembly {
            // load stake to callstack
            cache := sload(stake.slot)

            let shrs := shr(192, cache)

            let _eps := div(and(shr(96, cache), sub(shl(96, 1), 1)), shrs)

            let fee := div(mul(_eps, PROTOCOL_FEE_BPS), 10000)

            let premium := div(mul(_eps, shrs), 10000)

            let _msp := add(_eps, add(fee, premium))

            // ensure value >= msp
            if gt(_msp, callvalue()) {
                // ERRORx71
                mstore(0x00, 0x71)
                revert(31, 0x01)
            }

            // caculate value proveded over msp
            // will not overflow because of ERRORx71
            let overpay := sub(callvalue(), _msp)

            // add fee of overpay to fee
            fee := add(div(mul(overpay, PROTOCOL_FEE_BPS), 10000), fee)

            // combine the shares, eth, and protocol fee and add to stake cashe
            // cache = cache + [shares: 1 | eth: (value - fee) | fee: fee]
            cache := add(cache, or(shl(192, 1), or(shl(96, sub(callvalue(), fee)), fee)))

            sstore(stake.slot, cache)
        }

        emit Stake(bytes32(cache));
    }

    /// @notice handles isolated staking of eth
    /// @dev supply of eth goes up while supply of shares stays constant - increasing "minSharePrice"
    /// @param value the amount of eth being staked - must be some portion of msg.value
    function addStakedEth(uint96 value) internal {
        uint256 cache;

        assembly {
            cache := sload(stake.slot)

            let pro := div(mul(value, PROTOCOL_FEE_BPS), 10000)

            cache := add(cache, or(shl(96, sub(value, pro)), pro))

            sstore(stake.slot, cache)
        }

        emit Stake(bytes32(cache));
    }

    // @test manual
    // make sure the assembly works like regular (checked solidity)
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
        assembly {
            let shrs := shr(192, cache)
            ethPerShare := div(and(shr(96, cache), sub(shl(96, 1), 1)), shrs)
            protocolFee := div(mul(ethPerShare, PROTOCOL_FEE_BPS), 10000)
            premium := div(mul(ethPerShare, shrs), 10000)
            total := add(ethPerShare, add(protocolFee, premium))
        }
    }

    // @test manual
    function calculateEthPerShare(uint256 cache) internal pure returns (uint96 res) {
        assembly {
            res := shr(192, cache)
            res := div(and(shr(96, cache), sub(shl(96, 1), 1)), res)
        }
    }
}
