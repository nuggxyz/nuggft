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

    uint256 constant LIQUIDATION_PERIOD = 1000;

    event TakeLoan(uint160 tokenId, address account, uint256 eth);
    event Payoff(uint160 tokenId, address account, uint256 eth);
    event Liquidate(uint160 tokenId, address account, uint256 eth);

    function loan(uint160 tokenId) internal {
        // we know the loan data is blank because it is owned by the user
        require(TokenView.ownerOf(tokenId) == msg.sender, 'LOAN:L:0');

        TokenCore.approvedTransferToSelf(tokenId);

        uint96 principal = StakeView.getActiveEthPerShare();

        uint32 epoch = EpochView.activeEpoch();

        (uint256 loanData, ) = SwapPure.buildSwapData(epoch, uint160(msg.sender), principal, false);

        Loan.sstore(tokenId, loanData); // starting swap data

        // StakeCore.subStakedSharePayingSender();

        SafeTransferLib.safeTransferETH(msg.sender, principal);

        emit TakeLoan(tokenId, msg.sender, principal);
    }

    function rebalance(uint160 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:P:0');

        uint256 cache = Loan.sload(tokenId);

        require(cache != 0 && cache.account() == uint160(msg.sender), 'LOAN:P:2');

        uint96 curr = cache.eth(); // in their pocket atm

        uint96 fee = (curr * 100) / 10000; // fee to be paid

        require(fee <= msg.value, 'LOAN:RE:0');

        uint96 overpayment = msg.value.safe96() - fee;

        uint96 update = curr + fee;

        uint96 activeEps = StakeView.getActiveEthPerShare();

        uint96 reward = update >= activeEps ? 0 : activeEps - update;

        StakeCore.addStakedEth(fee);

        (uint256 loanData, ) = SwapPure.buildSwapData(cache.epoch() + 100, uint160(msg.sender), StakeView.getActiveEthPerShare(), false);

        Loan.sstore(tokenId, loanData); // starting swap data

        SafeTransferLib.safeTransferETH(msg.sender, reward + overpayment);

        emit Liquidate(tokenId, msg.sender, fee);
        emit Payoff(tokenId, msg.sender, overpayment);
        emit Payoff(tokenId, msg.sender, activeEps);
    }

    /// loan    -----
    /// extend
    /// extend
    /// extend
    /// payoff

    function payoff(uint160 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:P:0');

        uint256 cache = Loan.sload(tokenId);

        require(cache != 0, 'LOAN:P:2');

        uint32 epoch = EpochView.activeEpoch();

        uint96 min;

        if (cache.epoch() + LIQUIDATION_PERIOD >= epoch) {
            require(cache.account() == uint160(msg.sender), 'LOAN:P:1');
        }

        if (cache.account() == uint160(msg.sender)) {
            // PAYOFF
            min = (cache.eth() * 10100) / 10000; // ususally will be less!
        } else {
            // LIQUIDATION
            min = StakeView.getActiveEthPerShare();
        }

        require(msg.value >= min, 'LOAN:P:2');

        emit Payoff(tokenId, msg.sender, msg.value);

        Loan.spurge(tokenId);

        TokenCore.checkedTransferFromSelf(msg.sender, tokenId); // StakeCore.addStakedShareAndEth(msg.value.safe96());
    }

    function payoffAmount() internal view returns (uint256 res) {
        // 1% interest on top of the floor increase
        res = (StakeView.getActiveEthPerShare() * 10100) / 10000;
    }
}
