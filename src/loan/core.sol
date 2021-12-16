// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Global} from '../global/storage.sol';
import {Loan} from '../loan/storage.sol';

import {TokenCore} from '../token/core.sol';
import {StakeCore} from '../stake/core.sol';

import {SwapPure} from '../swap/pure.sol';

import {TokenView} from '../token/view.sol';
import {StakeView} from '../stake/view.sol';
import {EpochView} from '../epoch/view.sol';

library LoanCore {
    using SwapPure for uint256;

    uint256 constant LIQUIDATION_PERIOD = 1000;

    event TakeLoan(uint256 tokenId, address account, uint256 eth);
    event Payoff(uint256 tokenId, address account, uint256 eth);
    event Liquidate(uint256 tokenId, address account, uint256 eth);

    function loan(uint256 tokenId) internal {
        // we know the loan data is blank because it is owned by the user
        require(TokenView.ownerOf(tokenId) == msg.sender, 'LOAN:L:0');

        uint256 floor = StakeView.getActiveEthPerShare();

        TokenCore.approvedTransferToSelf(tokenId);

        uint256 epoch = EpochView.activeEpoch();

        (uint256 loanData, ) = uint256(0).account(uint160(msg.sender)).epoch(epoch).eth(floor);

        Global.ptr().loan.map[tokenId] = loanData; // starting swap data

        StakeCore.subStakedSharePayingSender();

        emit TakeLoan(tokenId, msg.sender, floor);
    }

    function payoff(uint256 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:P:0');

        uint256 loanData = Loan.get(tokenId);

        require(loanData.account() == uint160(msg.sender), 'LOAN:P:1');

        uint256 epoch = EpochView.activeEpoch();

        require(msg.value >= payoffAmount(), 'LOAN:P:2');

        delete Global.ptr().loan.map[tokenId];

        emit Payoff(tokenId, msg.sender, msg.value);

        TokenCore.checkedTransferFromSelf(msg.sender, tokenId);

        StakeCore.addStakedSharesAndEth(1, msg.value);
    }

    function liquidate(uint256 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:L:0');

        uint256 loanData = Global.ptr().loan.map[tokenId];

        require(loanData != 0, 'LOAN:L:1');

        uint256 epoch = EpochView.activeEpoch();

        require(loanData.epoch() + LIQUIDATION_PERIOD < epoch, 'LOAN:L:2');

        uint256 minOffer = StakeView.getActiveEthPerShare();

        require(msg.value >= minOffer, 'LOAN:L:3');

        delete Global.ptr().loan.map[tokenId];

        emit Liquidate(tokenId, msg.sender, msg.value);

        TokenCore.checkedTransferFromSelf(msg.sender, tokenId);

        StakeCore.addStakedSharesAndEth(1, msg.value);
    }

    function payoffAmount() internal view returns (uint256 res) {
        // 1% interest on top of the floor increase
        res = (StakeView.getActiveEthPerShare() * 10100) / 10000;
    }
}
