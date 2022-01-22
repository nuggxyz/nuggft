// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Loan} from '../interfaces/nuggftv1/INuggftV1Loan.sol';

import {CastLib} from '../libraries/CastLib.sol';
import {TransferLib} from '../libraries/TransferLib.sol';

import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';

import {NuggftV1Swap} from './NuggftV1Swap.sol';

abstract contract NuggftV1Loan is INuggftV1Loan, NuggftV1Swap {
    using CastLib for uint256;
    using NuggftV1AgentType for uint256;

    uint24 constant LIQUIDATION_PERIOD = 2;

    uint96 constant REBALANCE_FEE_BPS = 100;

    /// @inheritdoc INuggftV1Loan
    function loan(uint160 tokenId) external override {
        uint96 value = eps();
        uint256 active = epoch();

        uint256 agency__cache;

        // cache = NuggftV1AgentType.create(epoch(), msg.sender, eps(), NuggftV1AgentType.Flag.LOAN);

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, tokenId)
            mstore(add(ptr, 0x20), agency.slot)

            let loc := keccak256(ptr, 0x40)

            agency__cache := sload(loc)

            // require(isOwner(msg.sender, tokenId), hex'30');
            let a := iszero(eq(shr(96, shl(96, agency__cache)), caller()))
            let b := iszero(eq(shr(254, agency__cache), 0x03))
            if or(a, b) {
                mstore(0x00, 0x30)
                revert(31, 0x01)
            }

            value := div(value, LOSS)

            agency__cache := or(caller(), or(shl(160, value), or(shl(230, active), shl(254, 0x2))))

            sstore(loc, agency__cache)

            value := mul(value, LOSS)

            if iszero(call(gas(), caller(), value, 0, 0, 0, 0)) {
                mstore(0x00, 0x01)
                revert(0x1F, 0x01)
            }

            mstore(ptr, agency__cache)
            log2(ptr, 0x20, LOAN, tokenId)
        }

        // emit Loan(tokenId, bytes32(agency__cache));
    }

    /// @inheritdoc INuggftV1Loan
    function liquidate(uint160 tokenId) external payable override {
        uint256 agency__slot;
        uint256 agency__cache;

        uint256 active = epoch();

        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)
            agency__slot := keccak256(0x0, 64)

            agency__cache := sload(agency__slot)

            let loaner := shr(96, shl(96, agency__cache))

            // ensure that the agency flag is "SWAP" (0x01)
            if iszero(eq(shr(254, agency__cache), 0x02)) {
                mstore8(0x0, 0x33)
                revert(0x00, 0x01)
            }

            if iszero(eq(caller(), loaner)) {
                switch lt(add(shr(232, shl(2, agency__cache)), LIQUIDATION_PERIOD), active)
                case 1 {
                    log4(0x00, 0x00, TRANSFER, loaner, caller(), tokenId)
                }
                default {
                    mstore8(0x0, 0x31)
                    revert(0x00, 0x01)
                }
            }
        }

        uint96 val = uint96(((agency__cache << 26) >> 186) * LOSS);

        (uint96 fee, uint96 earned) = calc(val, eps());

        unchecked {
            uint96 debt = val + fee;

            earned += uint96(msg.value);

            require(debt <= earned, hex'32');

            earned -= debt;
        }

        addStakedEth(fee);

        assembly {
            //
            agency__cache := or(caller(), shl(254, 0x3))

            sstore(agency__slot, agency__cache)

            if iszero(call(gas(), caller(), earned, 0, 0, 0, 0)) {
                mstore(0x00, 0x01)
                revert(0x1F, 0x01)
            }

            mstore(0x00, agency__cache)
            log2(0x00, 0x32, LIQUIDATE, tokenId)
        }
    }

    /// @inheritdoc INuggftV1Loan
    function rebalance(uint160 tokenId) external payable override {
        uint256 cache;
        uint256 loc;
        uint96 beforeEth;
        uint96 shares;
        uint96 activeEps;
        uint96 principal;
        uint256 active = epoch();
        uint256 stake__cache;

        assembly {
            let ptr := mload(0x40)

            mstore(ptr, tokenId)
            mstore(add(ptr, 0x20), agency.slot)
            loc := keccak256(ptr, 0x40)

            cache := sload(loc)

            // make sure this nugg is loaned
            if iszero(eq(shr(254, cache), 0x02)) {
                mstore8(0x0, 0x33)
                revert(0x00, 0x01)
            }

            stake__cache := sload(stake.slot)

            beforeEth := shr(160, shl(64, stake__cache))

            shares := shr(192, stake__cache)

            activeEps := div(beforeEth, shares)

            principal := mul(shr(186, shl(26, cache)), LOSS)
        }

        (uint96 fee, uint96 earned) = calc(principal, activeEps);

        unchecked {
            beforeEth += fee;

            earned += uint96(msg.value);

            // make sure there is enough value to cover the fee
            require(fee <= earned, hex'3a');

            earned -= fee;
        }

        assembly {
            let pro := div(mul(fee, PROTOCOL_FEE_BPS), 10000)

            stake__cache := add(stake__cache, or(shl(96, sub(fee, pro)), pro))

            sstore(stake.slot, stake__cache)

            let afterEth := div(shr(160, shl(64, stake__cache)), mul(shares, LOSS))

            let account := shr(96, shl(96, cache))

            cache := or(shl(254, 0x2), or(shl(230, active), or(shl(160, afterEth), account)))

            sstore(loc, cache)

            if iszero(call(gas(), account, earned, 0, 0, 0, 0)) {
                mstore(0x00, 0x65)
                revert(0x1F, 0x01)
            }

            mstore(0x00, stake__cache)
            log1(0x00, 0x32, STAKE)

            mstore(0x00, cache)
            log2(0x00, 0x32, REBALANCE, tokenId)
        }
    }

    /// @inheritdoc INuggftV1Loan
    function multirebalance(uint160[] memory tokenIds) external payable override {
        uint96 acc = uint96(msg.value);
        uint96 accFee = 0;

        uint96 _eps = eps();

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 cache = agency[tokenIds[i]];

            // make sure this nugg is loaned
            require(cache.flag() == NuggftV1AgentType.Flag.LOAN, hex'33');

            require(msg.sender == cache.account(), hex'39');

            (uint96 fee, uint96 payment) = calc(cache.eth(), _eps);

            unchecked {
                payment += acc;

                // make sure there is enough value to cover the fee
                require(fee <= payment, hex'3a');

                payment -= fee;

                accFee += fee;

                acc = payment;
            }

            emit Rebalance(tokenIds[i], bytes32(cache));
        }

        addStakedEth(accFee);

        uint256 common = NuggftV1AgentType.create(epoch(), msg.sender, eps(), NuggftV1AgentType.Flag.LOAN);

        for (uint256 i = 0; i < tokenIds.length; i++) agency[tokenIds[i]] = common;

        // we transfer overearned to the owner
        TransferLib.give(msg.sender, acc);
    }

    function calc(uint96 principal, uint96 activeEps)
        internal
        pure
        returns (
            // uint96 debt,
            uint96 fee,
            uint96 earned
        )
    {
        // principal can never be below activeEps
        // assert(principal <= activeEps);

        assembly {
            fee := sub(activeEps, principal)

            let checkFee := div(principal, REBALANCE_FEE_BPS)

            if gt(fee, checkFee) {
                earned := sub(fee, checkFee)
                fee := checkFee
            }
        }
    }

    function loaned(uint160 tokenId) external view returns (bool res) {
        return agency[tokenId].flag() == NuggftV1AgentType.Flag.LOAN;
    }

    /// @inheritdoc INuggftV1Loan
    function valueForLiquidate(uint160 tokenId) external view returns (uint96 res) {
        uint256 cache = agency[tokenId];
        (uint96 fee, uint96 payment) = calc(cache.eth(), eps());
        res = cache.eth() + fee - payment;
    }

    /// @inheritdoc INuggftV1Loan
    function valueForRebalance(uint160 tokenId) external view returns (uint96 res) {
        uint256 cache = agency[tokenId];
        (uint96 fee, uint96 payment) = calc(cache.eth(), eps());
        if (fee > payment) return fee - payment;
    }

    /// @inheritdoc INuggftV1Loan
    function loanInfo(uint160 tokenId)
        external
        view
        override
        returns (
            bool isLoaned,
            uint96 debt,
            uint96 fee,
            uint96 earned,
            uint24 insolventEpoch
        )
    {
        uint256 cache = agency[tokenId];

        isLoaned = cache.flag() == NuggftV1AgentType.Flag.LOAN;

        insolventEpoch = cache.epoch() + LIQUIDATION_PERIOD;

        (fee, earned) = calc(cache.eth(), eps());

        debt = cache.eth() + fee;
    }
}
