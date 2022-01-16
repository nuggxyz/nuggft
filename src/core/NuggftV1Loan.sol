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

        approvedTransferToSelf(tokenId);

        uint96 value = loanData.eth();

        SafeTransferLib.safeTransferETH(msg.sender, value);

        emit Loan(tokenId, value);
    }

    /// @inheritdoc INuggftV1Loan
    function liquidate(uint160 tokenId) external payable override {
        (uint96 toLiquidate, uint96 toRebalance, uint96 owed, uint24 epochDue, address loaner) = loanInfo(tokenId);

        assert(address(this) == _ownerOf(tokenId)); // should always be true - should revert in loanInfo

        delete loans[tokenId];

        address benif = msg.sender;

        if (epochDue >= epoch()) {
            // if liquidaton deadline has not passed - check perrmission
            require(_isOperatorFor(msg.sender, loaner), 'L:1');
            benif = loaner;
        }

        uint96 value = msg.value.safe96();

        require(toLiquidate <= value, 'L:2');

        uint96 overpayment = value - toLiquidate;

        addStakedEth(toRebalance + overpayment);

        SafeTransferLib.safeTransferETH(benif, owed);

        checkedTransferFromSelf(benif, tokenId);

        emit Liquidate(tokenId, value, msg.sender);
    }

    /// @inheritdoc INuggftV1Loan
    function rebalance(uint160 tokenId) external payable override {
        (, uint96 toRebalance, uint96 earned, , address loaner) = loanInfo(tokenId);

        assert(address(this) == _ownerOf(tokenId)); // should always be true - should revert in loanInfo

        require(toRebalance <= msg.value, 'L:3');

        uint96 value = msg.value.safe96();

        // must be done before new principal is calculated
        addStakedEth(value);

        uint256 res = NuggftV1AgentType.newAgentType(epoch(), loaner, eps(), false);

        loans[tokenId] = res;

        SafeTransferLib.safeTransferETH(loaner, earned);

        emit Rebalance(tokenId, value);
    }

    /// @inheritdoc INuggftV1Loan
    function valueForLiquidate(uint160 tokenId) external view returns (uint96 res) {
        (res, , , , ) = loanInfo(tokenId);
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
            uint96 toRebalance,
            uint96 earned,
            uint24 epochDue,
            address loaner
        )
    {
        uint256 cache = loans[tokenId];

        loaner = cache.account();

        require(loaner != address(0), 'L:4');

        // the amount of eth currently loanded by user
        uint96 curr = cache.eth();

        uint96 activeEps = eps();

        assembly {
            toRebalance := div(mul(curr, REBALANCE_FEE_BPS), 10000)
        }

        toLiquidate = curr + toRebalance;

        unchecked {
            // value earned while lone was taken out
            earned = toLiquidate >= activeEps ? 0 : activeEps - toLiquidate;

            epochDue = cache.epoch() + LIQUIDATION_PERIOD;
        }
    }
}
