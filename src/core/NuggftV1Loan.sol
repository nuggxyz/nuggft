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
        uint256 next = genesis;

        uint96 value = eps();

        // cache = NuggftV1AgentType.create(epoch(), msg.sender, eps(), NuggftV1AgentType.Flag.LOAN);
        // agency[tokenId] = cache; // starting swap data
        // uint96 value = cache.eth();
        // TransferLib.give(msg.sender, value);

        assembly {
            let active := add(div(sub(number(), next), INTERVAL), OFFSET)

            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)
            let loc := keccak256(0x0, 64)

            let cache := sload(loc)

            // require(isOwner(msg.sender, tokenId), hex'30');
            let a := iszero(eq(and(cache, sub(shl(160, 1), 1)), caller()))
            let b := iszero(eq(shr(254, cache), 0x03))
            if or(a, b) {
                mstore(0x00, 0x30)
                revert(31, 0x01)
            }

            value := div(value, 1000000000)

            cache := or(caller(), or(shl(160, value), or(shl(230, active), shl(254, 0x2))))

            sstore(loc, cache)

            value := mul(value, 1000000000)

            if iszero(call(gas(), caller(), value, 0, 0, 0, 0)) {
                mstore(0, 0x01)
                revert(0x1F, 0x01)
            }
        }

        emit Loan(tokenId, value);
    }

    /// @inheritdoc INuggftV1Loan
    function liquidate(uint160 tokenId) external payable override {
        uint256 next = genesis;
        uint256 cache;
        uint256 loc;
        bool loaner;

        assembly {
            let active := add(div(sub(number(), next), INTERVAL), OFFSET)

            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)
            loc := keccak256(0x0, 64)

            cache := sload(loc)

            // require(cache.flag() == NuggftV1AgentType.Flag.LOAN, hex'33');
            if iszero(eq(shr(254, cache), 0x02)) {
                mstore(0x00, 0x33)
                revert(31, 0x01)
            }

            let ok := iszero(lt(add(shr(232, shl(2,  cache)), LIQUIDATION_PERIOD), active))

            loaner := eq(caller(), shr(96, shl(96,  cache)))

            if and(ok, iszero(loaner)) {
                mstore(0x00, 0x31)
                revert(31, 0x01)
            }
        }

        (uint96 fee, uint96 earned) = calc(cache.eth(), eps());

        unchecked {
            uint96 debt = cache.eth() + fee;

            earned += uint96(msg.value);

            require(debt <= earned, hex'32');

            earned -= debt;
        }

        addStakedEth(fee);

        assembly {
            cache := or(caller(), shl(254, 0x3))

            sstore(loc, cache)

            if iszero(call(gas(), caller(), earned, 0, 0, 0, 0)) {
                mstore(0, 0x01)
                revert(0x1F, 0x01)
            }
        }

        if (!loaner) {
            emit Transfer(address(uint160(cache)), address(this), tokenId);
            emit Transfer(address(this), msg.sender, tokenId);
        }

        emit Liquidate(tokenId, fee, msg.sender);
    }

    /// @inheritdoc INuggftV1Loan
    function rebalance(uint160 tokenId) external payable override {
        uint256 next = genesis;
        uint256 cache;
        uint256 loc;
        uint256 active;

        assembly {
             active := add(div(sub(number(), next), INTERVAL), OFFSET)

            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)
            loc := keccak256(0x0, 64)

            cache := sload(loc)

            // make sure this nugg is loaned
            if iszero(eq(shr(254, cache), 0x02)) {
                mstore(0x00, 0x33)
                revert(31, 0x01)
            }
        }

        uint96 beforeEth;

        uint96 shares;

        uint96 beforeEps;

        assembly {
            let scache := sload(stake.slot)

            beforeEth := shr(160, shl(64, scache))

            shares := shr(192, scache)

            beforeEps := div(beforeEth, shares)
        }

        (uint96 fee, uint96 earned) = calc(cache.eth(), beforeEps);

        unchecked {
            beforeEth += fee;

            earned += uint96(msg.value);

            // make sure there is enough value to cover the fee
            require(fee <= earned, hex'3a');

            earned -= fee;
        }

        addStakedEth(fee);

                emit Rebalance(tokenId, fee);


        assembly {
            let after := div(beforeEth, mul(shares, 1000000000))

            let acc := shr(96, shl(96,  cache))

            cache := or(acc, or(shl(160, after), or(shl(230, active), shl(254, 0x2))))

            sstore(loc, cache)


             if iszero(call(gas(), acc, earned, 0, 0, 0, 0)) {
                mstore(0x00, 0x65)
                revert(0x1F, 0x01)
            }
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

            emit Rebalance(tokenIds[i], fee);
        }

        addStakedEth(accFee);

        uint256 common = NuggftV1AgentType.create(epoch(), msg.sender, eps(), NuggftV1AgentType.Flag.LOAN);

        for (uint256 i = 0; i < tokenIds.length; i++) agency[tokenIds[i]] = common;

        // we transfer overearned to the owner
        TransferLib.give(msg.sender, acc);
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
}
