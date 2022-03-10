// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {NuggftV1Proof} from "./NuggftV1Proof.sol";

import {INuggftV1Migrator} from "../interfaces/nuggftv1/INuggftV1Migrator.sol";
import {INuggftV1Stake} from "../interfaces/nuggftv1/INuggftV1Stake.sol";

abstract contract NuggftV1Stake is INuggftV1Stake, NuggftV1Proof {
    address public migrator;

    uint256 public stake;

    /// @inheritdoc INuggftV1Stake
    function extract() external requiresTrust {
        uint256 cache = stake;

        payable(msg.sender).transfer((cache << 160) >> 160);

        cache = (cache >> 96) << 96;

        emit Stake(bytes32(cache));
    }

    /// @inheritdoc INuggftV1Stake
    function setMigrator(address _migrator) external requiresTrust {
        migrator = _migrator;

        emit MigratorV1Updated(_migrator);
    }

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
        res = uint64(stake >> 192);
    }

    /// @inheritdoc INuggftV1Stake
    function staked() public view override returns (uint96 res) {
        res = uint96(stake >> 96);
    }

    /// @inheritdoc INuggftV1Stake
    function proto() public view override returns (uint96 res) {
        res = uint96(stake);
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
        assembly {
            // load stake to callstack
            let cache := sload(stake.slot)

            let shrs := shr(192, cache)

            let _eps := div(shr(160, shl(64, cache)), shrs)

            let fee := div(_eps, PROTOCOL_FEE_BPS)

            let premium := div(mul(_eps, shrs), 10000)

            let _msp := add(_eps, add(fee, premium))

            // ensure value >= msp
            if gt(_msp, callvalue()) {
                mstore(0x00, Revert__Sig)
                mstore8(31, Error__0x71__ValueTooLow)
                revert(27, 0x5)
            }

            // caculate value proveded over msp
            // will not overflow because of ERRORx71
            let overpay := sub(callvalue(), _msp)

            // add fee of overpay to fee
            fee := add(div(overpay, PROTOCOL_FEE_BPS), fee)
            // fee := div(callvalue(), PROTOCOL_FEE_BPS)

            // update stake
            // =======================
            // stake = {
            //     shares  = prev + 1
            //     eth     = prev + (msg.value - fee)
            //     proto   = prev + fee
            // }
            // =======================
            cache := add(cache, or(shl(192, 1), or(shl(96, sub(callvalue(), fee)), fee)))

            sstore(stake.slot, cache)

            mstore(0x40, cache)
        }
    }

    /// @notice handles isolated staking of eth
    /// @dev supply of eth goes up while supply of shares stays constant - increasing "minSharePrice"
    /// @param value the amount of eth being staked - must be some portion of msg.value
    function addStakedEth(uint96 value) internal {
        assembly {
            let pro := div(value, PROTOCOL_FEE_BPS)

            let cache := add(sload(stake.slot), or(shl(96, sub(value, pro)), pro))

            sstore(stake.slot, cache)

            // let ptr := mload(0x40)
            // mstore(ptr, callvalue())
            // mstore(add(0x20, ptr), 0x01)
            mstore(0x00, cache)
            log1(0x00, 0x20, Event__Stake)
        }
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
            protocolFee := div(ethPerShare, PROTOCOL_FEE_BPS)
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
