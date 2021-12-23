// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ILoanExternal} from '../interfaces/nuggft/ILoanExternal.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Global} from '../global/GlobalStorage.sol';
import {Loan} from '../loan/LoanStorage.sol';

import {TokenCore} from '../token/TokenCore.sol';
import {StakeCore} from '../stake/StakeCore.sol';

import {SwapPure} from '../swap/SwapPure.sol';

import {TokenView} from '../token/TokenView.sol';
import {EpochCore} from '../epoch/EpochCore.sol';

abstract contract LoanExternal is ILoanExternal {
    using SafeCastLib for uint256;
    using SwapPure for uint256;

    uint32 constant LIQUIDATION_PERIOD = 1000;
    uint96 constant REBALANCE_FEE_BPS = 100;

    /// @inheritdoc ILoanExternal
    function loan(uint160 tokenId) external override {
        // we know the loan data is blank because it is owned by the user
        require(TokenView.isOperatorForOwner(msg.sender, tokenId), 'L:2');

        uint96 principal = StakeCore.activeEthPerShare();

        uint32 epoch = EpochCore.activeEpoch();

        (uint256 loanData, ) = SwapPure.buildSwapData(epoch, uint160(msg.sender), principal, false);

        Loan.sstore(tokenId, loanData); // starting swap data

        emit TakeLoan(tokenId, principal);

        TokenCore.approvedTransferToSelf(tokenId);

        SafeTransferLib.safeTransferETH(msg.sender, principal);
    }

    /// @inheritdoc ILoanExternal
    function payoff(uint160 tokenId) external payable override {
        require(address(this) == TokenView.ownerOf(tokenId), 'L:6');

        (uint96 toPayoff, uint96 toRebalance, uint96 earned, uint96 epochDue, address loaner) = loanInfo(tokenId);

        Loan.spurge(tokenId); // starting swap data

        uint32 epoch = EpochCore.activeEpoch();

        // delay liquidation
        if (epochDue >= epoch) require(TokenView.isOperatorFor(msg.sender, loaner), 'L:2');

        require(toPayoff <= msg.value, 'L:8');

        uint96 value = msg.value.safe96();

        uint96 overpayment = value - toRebalance;

        uint96 owed = earned + overpayment;

        emit Rebalance(tokenId, toRebalance, earned);

        emit Payoff(tokenId, msg.sender, toPayoff);

        StakeCore.addStakedEth(toRebalance);

        SafeTransferLib.safeTransferETH(msg.sender, owed);

        TokenCore.checkedTransferFromSelf(msg.sender, tokenId);
    }

    /// @inheritdoc ILoanExternal
    function rebalance(uint160 tokenId) external payable override {
        require(address(this) == TokenView.ownerOf(tokenId), 'L:3');

        (, uint96 toRebalance, uint96 earned, uint32 epochDue, address loaner) = loanInfo(tokenId);

        require(TokenView.isOperatorFor(msg.sender, loaner), 'L:4');

        require(toRebalance <= msg.value, 'L:5'); // 70

        StakeCore.addStakedEth(toRebalance);

        uint96 newPrincipal = StakeCore.activeEthPerShare();

        (uint256 loanData, uint96 dust) = SwapPure.buildSwapData(epochDue, uint160(msg.sender), newPrincipal, false);

        Loan.sstore(tokenId, loanData); // starting swap data

        uint96 overpayment = msg.value.safe96() - toRebalance; // 1 wei

        uint96 owed = earned + overpayment + dust;

        emit Rebalance(tokenId, toRebalance, earned);

        SafeTransferLib.safeTransferETH(msg.sender, owed);
    }

    /// @inheritdoc ILoanExternal
    function loanInfo(uint160 tokenId)
        public
        view
        returns (
            uint96 toPayoff,
            uint96 toRebalance,
            uint96 earned,
            uint32 epochDue,
            address loaner
        )
    {
        uint256 state = Loan.sload(tokenId);

        // ensure loan exists
        require(state != 0, 'L:1');

        // the amount of eth currently loanded by user
        uint96 curr = state.eth();

        uint96 activeEps = StakeCore.activeEthPerShare();

        toRebalance = ((curr * REBALANCE_FEE_BPS) / 10000);

        toPayoff = curr + toRebalance;

        // value earned while lone was taken out
        earned = toPayoff >= activeEps ? 0 : activeEps - toPayoff;

        epochDue = state.epoch() + LIQUIDATION_PERIOD;

        loaner = address(state.account());
    }

    /// @inheritdoc ILoanExternal
    function valueForPayoff(uint160 tokenId) external view returns (uint96 res) {
        (res, , , , ) = loanInfo(tokenId);
    }

    /// @inheritdoc ILoanExternal
    function valueForRebalance(uint160 tokenId) external view returns (uint96 res) {
        (, res, , , ) = loanInfo(tokenId);
    }
}
