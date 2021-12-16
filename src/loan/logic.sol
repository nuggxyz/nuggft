// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {TokenView} from '../token/view.sol';
import {TokenLogic} from '../token/logic.sol';

import {SwapPure} from '../swap/pure.sol';

library LoanLogic {
    using SwapPure for uint256;

    uint256 constant LIQUIDATION_PERIOD = 1000;

    event TakeLoan(uint256 tokenId, address account, uint256 eth);
    event Payoff(uint256 tokenId, address account, uint256 eth);
    event Liquidate(uint256 tokenId, address account, uint256 eth);

    function loan(uint256 tokenId) internal {
        // we know the loan data is blank because it is owned by the user
        require(TokenLogic.ownerOf(tokenId) == msg.sender, 'LOAN:L:0');

        uint256 floor = StakeView.getActiveEthPerShare();

        TokenLogic.approvedTransferToSelf(msg.sender, tokenId);

        uint256 epoch = EpochView.activeEpoch();

        (uint256 loanData, ) = uint256(0).account(uint160(msg.sender)).epoch(epoch).eth(floor);

        Global.ptr().loans[tokenId] = loanData; // starting swap data

        StakeLogic.subStakedSharePayingSender();

        emit TakeLoan(tokenId, msg.sender, floor);
    }

    function payoff(uint256 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:P:0');

        uint256 loanData = nuggft._loans[tokenId];

        require(loanData.account() == uint160(msg.sender), 'LOAN:P:1');

        uint256 epoch = EpochView.activeEpoch();

        require(msg.value >= payoffAmount(nuggft), 'LOAN:P:2');

        delete Global.ptr().loans[tokenId];

        emit Payoff(tokenId, msg.sender, msg.value);

        nuggft.checkedTransferFromSelf(msg.sender, tokenId);

        nuggft.addStakedSharesAndEth(1, msg.value);
    }

    function liquidate(uint256 tokenId) internal {
        require(address(this) == TokenView.ownerOf(tokenId), 'LOAN:L:0');

        uint256 loanData = LoanView.data(tokenId);

        require(loanData != 0, 'LOAN:L:1');

        uint256 epoch = EpochView.activeEpoch();

        require(loanData.epoch() + LIQUIDATION_PERIOD < epoch, 'LOAN:L:2');

        uint256 minOffer = StakeView.getActiveEthPerShare();

        require(msg.value >= minOffer, 'LOAN:L:3');

        delete Global.ptr().loans[tokenId];

        emit Liquidate(tokenId, msg.sender, msg.value);

        TokenLogic.checkedTransferFromSelf(msg.sender, tokenId);

        StakeLogic.addStakedSharesAndEth(1, msg.value);
    }

    function payoffAmount() internal view returns (uint256 res) {
        // 1% interest on top of the floor increase
        res = (StakeView.getActiveEthPerShare() * 10100) / 10000;
    }
}
