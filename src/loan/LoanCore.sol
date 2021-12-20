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
import {StakeView} from '../stake/StakeView.sol';
import {EpochView} from '../epoch/EpochView.sol';

library LoanCore {
    using SafeCastLib for uint256;
    using SwapPure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    uint32 constant LIQUIDATION_PERIOD = 1000;
    uint96 constant REBALANCE_FEE_BPS = 100;
    uint32 constant REBALANCE_PERIOD_INCREASE = 1000;

    event TakeLoan(uint160 tokenId, address account, uint96 eth);
    event Payoff(uint160 tokenId, address account, uint96 eth);
    event Rebalance(uint160 tokenId, uint96 eth);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            LOAN MANAGEMENT
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    // @hh system tests
    function loan(uint160 tokenId) internal {
        // we know the loan data is blank because it is owned by the user
        require(TokenView.ownerOf(tokenId) == msg.sender, 'LOAN:L:0');

        TokenCore.approvedTransferToSelf(tokenId);

        uint96 principal = StakeView.getActiveEthPerShare();

        uint32 epoch = EpochView.activeEpoch();

        (uint256 loanData, ) = SwapPure.buildSwapData(epoch, uint160(msg.sender), principal, false);

        Loan.sstore(tokenId, loanData); // starting swap data

        SafeTransferLib.safeTransferETH(msg.sender, principal);

        emit TakeLoan(tokenId, msg.sender, principal);
    }

    // @hh system tests
    function rebalance(uint160 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:P:0');

        uint256 cache = Loan.sload(tokenId);

        require(cache != 0 && cache.account() == uint160(msg.sender), 'LOAN:P:2');

        uint96 curr = cache.eth(); // in their pocket atm

        uint96 fee = ((curr * REBALANCE_FEE_BPS) / 10000); // fee to be paid 69

        require(fee <= msg.value, 'LOAN:RE:0'); // 70

        uint96 preEps = StakeView.getActiveEthPerShare();

        StakeCore.addStakedEth(fee);

        (uint256 loanData, uint96 dust) = SwapPure.buildSwapData(
            cache.epoch() + REBALANCE_PERIOD_INCREASE,
            uint160(msg.sender),
            StakeView.getActiveEthPerShare(),
            false
        );

        Loan.sstore(tokenId, loanData); // starting swap data

        uint96 overpayment = msg.value.safe96() - fee; // 1 wei

        uint96 update = curr + fee;

        // value earned while lone was taken out
        uint96 earnings = update >= preEps ? 0 : preEps - update;

        uint96 owed = earnings + overpayment + dust;

        SafeTransferLib.safeTransferETH(msg.sender, earnings + overpayment + dust);

        emit Rebalance(tokenId, owed);
    }

    // @hh system tests
    function payoff(uint160 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:P:0');

        uint256 cache = Loan.sload(tokenId);

        Loan.spurge(tokenId); // starting swap data

        uint32 epoch = EpochView.activeEpoch();

        if (cache.epoch() + LIQUIDATION_PERIOD >= epoch) {
            require(cache.account() == uint160(msg.sender), 'LOAN:P:1');
        }

        require(cache != 0, 'LOAN:P:2');

        uint96 curr = cache.eth(); // in their pocket atm

        uint96 fee = (curr * REBALANCE_FEE_BPS) / 10000; // fee to be paid

        require(fee + curr <= msg.value, 'LOAN:RE:0');

        uint96 value = msg.value.safe96();

        uint96 overpayment = value - fee;

        uint96 update = curr + fee;

        uint96 activeEps = StakeView.getActiveEthPerShare();

        // value earned while lone was taken out
        uint96 earnings = update >= activeEps ? 0 : activeEps - update;

        StakeCore.addStakedEth(fee);

        SafeTransferLib.safeTransferETH(msg.sender, earnings + overpayment);

        TokenCore.checkedTransferFromSelf(msg.sender, tokenId);

        emit Payoff(tokenId, msg.sender, value);
    }
}
