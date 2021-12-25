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

    uint32 constant LIQUIDATION_PERIOD = 1000;
    uint96 constant REBALANCE_FEE_BPS = 100;

    /// @inheritdoc INuggftV1Loan
    function loan(uint160 tokenId) external override {
        address sender = _ownerOf(tokenId);

        require(_isOperatorFor(msg.sender, sender), 'L:0');

        uint96 principal = totalEthPerShare();

        (uint256 loanData, ) = NuggftV1AgentType.newAgentType(epoch(), sender, principal, false);

        loans[tokenId] = loanData; // starting swap data

        emit TakeLoan(tokenId, principal);

        approvedTransferToSelf(tokenId);

        SafeTransferLib.safeTransferETH(sender, principal);
    }

    /// @inheritdoc INuggftV1Loan
    function payoff(uint160 tokenId) external payable override {
        (uint96 toPayoff, uint96 toRebalance, uint96 earned, uint96 epochDue, address loaner) = loanInfo(tokenId);

        assert(address(this) == _ownerOf(tokenId)); // should always be true - should revert in loanInfo

        delete loans[tokenId];

        address benif = msg.sender;

        // delay liquidation
        if (epochDue >= epoch()) {
            require(_isOperatorFor(msg.sender, loaner), 'L:1');
            benif = loaner;
        }

        uint96 value = msg.value.safe96();

        require(toPayoff <= value, 'L:2');

        uint96 overpayment = value - toRebalance;

        uint96 owed = earned + overpayment;

        emit Rebalance(tokenId, toRebalance, earned);

        emit Payoff(tokenId, benif, toPayoff);

        addStakedEth(toRebalance);

        SafeTransferLib.safeTransferETH(benif, owed);

        checkedTransferFromSelf(benif, tokenId);
    }

    /// @inheritdoc INuggftV1Loan
    function rebalance(uint160 tokenId) external payable override {
        NuggftV1AgentType.Memory memory loanState = NuggftV1AgentType.unpack(loans[tokenId]);

        (, uint96 toRebalance, uint96 earned, , address loaner) = loanInfo(loanState);

        assert(address(this) == _ownerOf(tokenId)); // should always be true - should revert in loanInfo

        require(toRebalance <= msg.value, 'L:3');

        // has to be done before newPrincipal is calculated
        addStakedEth(toRebalance);

        // new base epoch
        loanState.epoch = epoch();

        // newPrincipal
        loanState.eth = totalEthPerShare();

        (uint256 res, uint96 dust) = NuggftV1AgentType.pack(loanState);

        loans[tokenId] = res;

        uint96 overpayment = msg.value.safe96() - toRebalance;

        uint96 owed = earned + overpayment + dust;

        emit Rebalance(tokenId, toRebalance, earned);

        SafeTransferLib.safeTransferETH(loaner, owed);
    }

    /// @inheritdoc INuggftV1Loan
    function valueForPayoff(uint160 tokenId) external view returns (uint96 res) {
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
            uint96 toPayoff,
            uint96 toRebalance,
            uint96 earned,
            uint32 epochDue,
            address loaner
        )
    {
        return loanInfo(NuggftV1AgentType.unpack(loans[tokenId]));
    }

    function loanInfo(NuggftV1AgentType.Memory memory loanState)
        internal
        view
        returns (
            uint96 toPayoff,
            uint96 toRebalance,
            uint96 earned,
            uint32 epochDue,
            address loaner
        )
    {
        // AgentType memory loanState = NuggftV1AgentType.sload(loans[tokenId]);

        // ensure loan exists
        require(loanState.account != address(0), 'L:4');

        // the amount of eth currently loanded by user
        uint96 curr = loanState.eth;

        uint96 activeEps = totalEthPerShare();

        toRebalance = ((curr * REBALANCE_FEE_BPS) / 10000);

        toPayoff = curr + toRebalance;

        // value earned while lone was taken out
        earned = toPayoff >= activeEps ? 0 : activeEps - toPayoff;

        epochDue = loanState.epoch + LIQUIDATION_PERIOD;

        loaner = loanState.account;
    }
}
