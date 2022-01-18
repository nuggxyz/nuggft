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

    mapping(uint160 => uint256) loans;

    uint24 constant LIQUIDATION_PERIOD = 2;

    uint96 constant REBALANCE_FEE_BPS = 100;

    /// @inheritdoc INuggftV1Loan
    function loan(uint160 tokenId) external override {
        require(_ownerOf(tokenId) == msg.sender, 'L:0');

        uint256 loanData = NuggftV1AgentType.newAgentType(epoch(), msg.sender, eps(), false);

        loans[tokenId] = loanData; // starting swap data

        uint96 value = loanData.eth();

        SafeTransferLib.safeTransferETH(msg.sender, value);

        emit Loan(tokenId, value);
    }

    /// @inheritdoc INuggftV1Loan
    function liquidate(uint160 tokenId) external payable override {
        uint256 cache = loans[tokenId];

        delete loans[tokenId];

        require(cache != 0, 'L:X');

        uint24 epochDue = cache.epoch() + LIQUIDATION_PERIOD;

        if (epochDue >= epoch()) {
            // if liquidaton deadline has not passed - check perrmission
            require(msg.sender == cache.account(), 'L:1');
        } else {
            // loan is past due
            if (msg.sender != cache.account()) {
                liquidationTransfer(msg.sender, tokenId);
            }
        }

        uint96 activeEps = eps();

        (uint96 toLiquidate, uint96 fee, uint96 earned) = calc(cache.eth(), activeEps);

        toLiquidate = toLiquidate == 0 ? activeEps : toLiquidate;

        uint96 value = uint96(msg.value);

        require(toLiquidate <= value, 'L:2');

        unchecked {
            //  (value - toLiquidate) = overpayment;
            addStakedEth(fee + (value - toLiquidate));
        }

        SafeTransferLib.safeTransferETH(msg.sender, earned);

        emit Liquidate(tokenId, value, msg.sender);
    }

    /// @inheritdoc INuggftV1Loan
    function rebalance(uint160 tokenId) external override {
        uint256 cache = loans[tokenId];

        require(cache != 0, 'L:X');

        uint96 acitveEps = eps();

        (, uint96 fee, uint96 earned) = calc(cache.eth(), acitveEps);

        require(fee != 0, 'L:9');

        // must be done before new principal is calculated
        addStakedEth(fee);

        loans[tokenId] = NuggftV1AgentType.newAgentType(epoch(), cache.account(), acitveEps, false);

        SafeTransferLib.safeTransferETH(cache.account(), earned);

        emit Rebalance(tokenId, fee);
    }

    function liquidationTransfer(address to, uint160 tokenId) internal {
        owners[tokenId] = to;

        emit Transfer(address(this), to, tokenId);
    }

    function loaned(uint160 tokenId) public view returns (bool res) {
        return loans[tokenId] != 0;
    }

    /// @inheritdoc INuggftV1Loan
    function valueForLiquidate(uint160 tokenId) external view returns (uint96 res) {
        (res, , , , ) = loanInfo(tokenId);
        if (res == 0) return eps();
    }

    /// @inheritdoc INuggftV1Loan
    function valueForRebalance(uint160 tokenId) external view returns (uint96 res) {
        (, res, , , ) = loanInfo(tokenId);
    }

    /// @inheritdoc INuggftV1Loan
    function loanInfo(uint160 tokenId)
        public
        view
        override
        returns (
            uint96 toLiquidate,
            uint96 fee,
            uint96 earned,
            uint24 epochDue,
            address loaner
        )
    {
        uint256 cache = loans[tokenId];

        loaner = cache.account();

        epochDue = cache.epoch() + LIQUIDATION_PERIOD;

        (toLiquidate, fee, earned) = calc(cache.eth(), eps());
    }

    // flashloaning nuggs

    function calc(uint96 principal, uint96 activeEps)
        internal
        pure
        returns (
            uint96 toLiquidate,
            uint96 fee,
            uint96 earned
        )
    {
        // // principal can never be below activeEps
        assert(principal <= activeEps);

        assembly {
            let checkFee := div(principal, REBALANCE_FEE_BPS)

            // (activeEps - fee >= principal)
            if gt(sub(activeEps, checkFee), principal) {
                fee := checkFee
                toLiquidate := add(principal, fee)
                earned := sub(activeEps, toLiquidate)
            }
        }
    }
}
