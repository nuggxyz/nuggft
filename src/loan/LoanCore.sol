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

    event TakeLoan(uint256 tokenId, address account, uint256 eth);
    event Payoff(uint256 tokenId, address account, uint256 eth);
    event Liquidate(uint256 tokenId, address account, uint256 eth);

    function loan(uint256 tokenId) internal {
        // we know the loan data is blank because it is owned by the user
        require(TokenView.ownerOf(tokenId) == msg.sender, 'LOAN:L:0');

        uint256 principal = (StakeView.getActiveEthPerShare() * 6900) / 10000;

        TokenCore.approvedTransferToSelf(tokenId);

        uint32 epoch = EpochView.activeEpoch();

        (uint256 loanData, ) = SwapPure.buildSwapData(epoch, uint160(msg.sender), principal, false);

        Loan.sstore(tokenId, loanData); // starting swap data

        StakeCore.subStakedSharePayingSender();

        emit TakeLoan(tokenId, msg.sender, principal);
    }

    function payoff(uint256 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:P:0');

        uint256 cache = Loan.sload(tokenId);

        Loan.spurge(tokenId);

        uint256 epoch = EpochView.activeEpoch();

        uint256 min;

        if (cache.epoch() + LIQUIDATION_PERIOD >= epoch) {
            // PAYOFF
            require(cache.account() == uint160(msg.sender), 'LOAN:P:1');
            min = (cache.eth() * 10100) / 10000;
        } else {
            // LIQUIDATION
            min = StakeView.getActiveEthPerShare();
        }

        require(msg.value >= min, 'LOAN:P:2');

        emit Payoff(tokenId, msg.sender, msg.value);

        StakeCore.addStakedShareAndEth(msg.value.safe192());

        TokenCore.checkedTransferFromSelf(msg.sender, tokenId);
    }

    // function liquidate(uint256 tokenId) internal {
    //     require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:L:0');

    //     uint256 loanData = Global.ptr().loan.map[tokenId];

    //     require(loanData != 0, 'LOAN:L:1');

    //     uint256 epoch = EpochView.activeEpoch();

    //     require(loanData.epoch() + LIQUIDATION_PERIOD < epoch, 'LOAN:L:2');

    //     uint256 minOffer = StakeView.getActiveEthPerShare();

    //     require(msg.value >= minOffer, 'LOAN:L:3');

    //     Loan.spurge(tokenId);

    //     emit Liquidate(tokenId, msg.sender, msg.value);

    //     TokenCore.checkedTransferFromSelf(msg.sender, tokenId);

    //     StakeCore.addStakedShareAndEth(msg.value.safe192());
    // }

    function payoffAmount() internal view returns (uint256 res) {
        // 1% interest on top of the floor increase
        res = (StakeView.getActiveEthPerShare() * 10100) / 10000;
    }
}
