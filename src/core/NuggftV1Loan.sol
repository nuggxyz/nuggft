// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Loan} from '../interfaces/nuggftv1/INuggftV1Loan.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';

import {NuggftV1Swap} from './NuggftV1Swap.sol';

abstract contract NuggftV1Loan is INuggftV1Loan, NuggftV1Swap {
    using SafeCastLib for uint256;
    using NuggftV1AgentType for uint256;

    uint24 constant LIQUIDATION_PERIOD = 2;

    uint96 constant REBALANCE_FEE_BPS = 100;

    /// @inheritdoc INuggftV1Loan
    function loan(uint160 tokenId) external override {
        uint256 cache = agency[tokenId];

        require(cache.account() == msg.sender, hex'30');

        cache = NuggftV1AgentType.newAgentType(epoch(), msg.sender, eps(), true);

        agency[tokenId] = cache; // starting swap data

        uint96 value = cache.eth();

        SafeTransferLib.safeTransferETH(msg.sender, value);

        emit Loan(tokenId, value);
    }

    /// @inheritdoc INuggftV1Loan
    function liquidate(uint160 tokenId) external payable override {
        uint256 cache = agency[tokenId];

        require(cache.flag(), hex'33');

        if (cache.epoch() + LIQUIDATION_PERIOD >= epoch()) {
            // if liquidaton deadline has not passed - check perrmission
            require(msg.sender == cache.account(), hex'31');
        } else {
            // loan is past due
            if (msg.sender != cache.account()) {
                emit Transfer(cache.account(), address(this), tokenId);
                emit Transfer(address(this), msg.sender, tokenId);
            }
        }

        agency[tokenId] = NuggftV1AgentType.newAgentType(0, msg.sender, 0, false);

        (uint96 fee, uint96 earned) = calc(cache.eth(), eps());

        unchecked {
            uint96 debt = cache.eth() + fee;

            earned += uint96(msg.value);

            require(debt <= earned, hex'32');

            earned -= debt;
        }

        addStakedEth(fee);

        SafeTransferLib.safeTransferETH(msg.sender, earned);

        emit Liquidate(tokenId, fee, msg.sender);
    }

    /// @inheritdoc INuggftV1Loan
    function rebalance(uint160 tokenId) external payable override {
        uint256 cache = agency[tokenId];

        // make sure this nugg is loaned
        require(cache.flag(), hex'33');

        require(msg.sender == cache.account(), hex'39');

        (uint96 fee, uint96 earned) = calc(cache.eth(), eps());

        unchecked {
            earned += uint96(msg.value);

            // make sure there is enough value to cover the fee
            require(fee <= earned, hex'3a');

            earned -= fee;
        }

        addStakedEth(fee);

        // we need to recalculate eps here because it has changed after "addStakedEth"
        agency[tokenId] = NuggftV1AgentType.newAgentType(epoch(), cache.account(), eps(), true);

        // we transfer overearned to the owner
        SafeTransferLib.safeTransferETH(cache.account(), earned);

        emit Rebalance(tokenId, fee);
    }

    /// @inheritdoc INuggftV1Loan
    function multirebalance(uint160[] memory tokenIds) external payable override {
        uint96 acc = uint96(msg.value);
        uint96 accFee = 0;

        uint96 _eps = eps();

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 cache = agency[tokenIds[i]];

            // make sure this nugg is loaned
            require(cache.flag(), hex'33');

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

        uint256 common = NuggftV1AgentType.newAgentType(epoch(), msg.sender, eps(), true);

        for (uint256 i = 0; i < tokenIds.length; i++) agency[tokenIds[i]] = common;

        // we transfer overearned to the owner
        SafeTransferLib.safeTransferETH(msg.sender, acc);
    }

    function loaned(uint160 tokenId) external view returns (bool res) {
        return agency[tokenId].flag();
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

        isLoaned = cache.flag();

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
