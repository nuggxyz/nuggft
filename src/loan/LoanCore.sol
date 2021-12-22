// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Global} from '../global/GlobalStorage.sol';
import {Loan} from '../loan/LoanStorage.sol';

import {TokenCore} from '../token/TokenCore.sol';
import {StakeCore} from '../stake/StakeCore.sol';

import {SwapPure} from '../swap/SwapPure.sol';

import {TokenView} from '../token/TokenView.sol';
import {EpochCore} from '../epoch/EpochCore.sol';

library LoanCore {
    using SafeCastLib for uint256;
    using SwapPure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    uint32 constant LIQUIDATION_PERIOD = 1000;
    uint96 constant REBALANCE_FEE_BPS = 100;

    event TakeLoan(uint160 tokenId, uint96 principal);
    event Payoff(uint160 tokenId, address account, uint96 payoffAmount);
    event Rebalance(uint160 tokenId, uint96 fee, uint96 earned);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice for a nugg's active loan: calculates the current min eth a user must send to payoff or rebalance
    /// @dev contract ->
    /// @dev frontend -> used to set the amount of eth for user
    /// @param tokenId the token who's current loan to check
    /// @return toPayoff ->  the current amount loaned out, plus the final rebalance fee
    /// @return toRebalance ->  the fee a user must pay to rebalance (and extend) the loan on their nugg
    /// @return earned -> the amount of eth the minSharePrice has increased since loan was last rebalanced
    /// @return epochDue -> the final epoch a user is safe from liquidation (inclusive)
    /// @return loaner -> the user responsable for the loan
    function verifiedLoanInfo(uint160 tokenId)
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
        uint256 cache = Loan.sload(tokenId);

        // ensure loan exists
        require(cache != 0, 'L:1');

        // the amount of eth currently loanded by user
        uint96 curr = cache.eth();

        uint96 activeEps = StakeCore.activeEthPerShare();

        toRebalance = ((curr * REBALANCE_FEE_BPS) / 10000);

        toPayoff = curr + toRebalance;

        // value earned while lone was taken out
        earned = toPayoff >= activeEps ? 0 : activeEps - toPayoff;

        epochDue = cache.epoch() + LIQUIDATION_PERIOD;

        loaner = address(cache.account());
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            LOAN MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    // @hh system tests
    function loan(uint160 tokenId) internal {
        // we know the loan data is blank because it is owned by the user
        require(TokenView.ownerOf(tokenId) == msg.sender, 'L:2');

        TokenCore.approvedTransferToSelf(tokenId);

        uint96 principal = StakeCore.activeEthPerShare();

        uint32 epoch = EpochCore.activeEpoch();

        (uint256 loanData, ) = SwapPure.buildSwapData(epoch, uint160(msg.sender), principal, false);

        Loan.sstore(tokenId, loanData); // starting swap data

        SafeTransferLib.safeTransferETH(msg.sender, principal);

        emit TakeLoan(tokenId, principal);
    }

    // @hh system tests
    function rebalance(uint160 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'L:3');

        (, uint96 toRebalance, uint96 earned, uint32 epochDue, address loaner) = verifiedLoanInfo(tokenId);

        require(loaner == msg.sender, 'L:4');

        require(toRebalance <= msg.value, 'L:5'); // 70

        StakeCore.addStakedEth(toRebalance);

        uint96 newPrincipal = StakeCore.activeEthPerShare();

        (uint256 loanData, uint96 dust) = SwapPure.buildSwapData(epochDue, uint160(msg.sender), newPrincipal, false);

        Loan.sstore(tokenId, loanData); // starting swap data

        uint96 overpayment = msg.value.safe96() - toRebalance; // 1 wei

        uint96 owed = earned + overpayment + dust;

        SafeTransferLib.safeTransferETH(msg.sender, owed);

        emit Rebalance(tokenId, toRebalance, earned);
    }

    // @hh system tests
    function payoff(uint160 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'L:6');

        (uint96 toPayoff, uint96 toRebalance, uint96 earned, uint96 epochDue, address loaner) = verifiedLoanInfo(tokenId);

        Loan.spurge(tokenId); // starting swap data

        uint32 epoch = EpochCore.activeEpoch();

        // delay liquidation
        if (epochDue >= epoch) require(loaner == msg.sender, 'L:7');

        require(toPayoff <= msg.value, 'L:8');

        uint96 value = msg.value.safe96();

        uint96 overpayment = value - toRebalance;

        uint96 owed = earned + overpayment;

        StakeCore.addStakedEth(toRebalance);

        SafeTransferLib.safeTransferETH(msg.sender, owed);

        TokenCore.checkedTransferFromSelf(msg.sender, tokenId);

        emit Rebalance(tokenId, toRebalance, earned);

        emit Payoff(tokenId, msg.sender, toPayoff);
    }
}
