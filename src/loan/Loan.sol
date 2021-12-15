// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/SafeTransferLib.sol';

import '../token/Token.sol';
import '../token/TokenLib.sol';

import '../stake/StakeLib.sol';

import '../libraries/EpochLib.sol';
import '../libraries/QuadMath.sol';

library Loan {
    using SafeTransferLib for address;
    using SwapShiftLib for uint256;
    using EpochLib for uint256;
    using QuadMath for uint256;

    using StakeLib for Token.Storage;
    using TokenLib for Token.Storage;
    using Token for Token.Storage;

    uint256 constant LIQUIDATION_PERIOD = 1000;

    event TakeLoan(uint256 tokenId, address account, uint256 eth);
    event Payoff(uint256 tokenId, address account, uint256 eth);
    event Liquidate(uint256 tokenId, address account, uint256 eth);

    function loan(
        Token.Storage storage nuggft,
        uint256 genesis,
        uint256 tokenId
    ) internal {
        // we know the loan data is blank because it is owned by the user
        require(nuggft._ownerOf(tokenId) == msg.sender, 'LOAN:L:0');

        uint256 floor = nuggft.getActiveEthPerShare();

        emit TakeLoan(tokenId, msg.sender, floor);

        nuggft.approvedTransferToSelf(msg.sender, tokenId);

        uint256 epoch = genesis.activeEpoch();

        (uint256 loanData, ) = uint256(0).account(uint160(msg.sender)).epoch(epoch).eth(floor);

        nuggft._loans[tokenId] = loanData; // starting swap data

        msg.sender.safeTransferETH(floor);

        nuggft.subStakedEth(floor);

        nuggft.subStakedShares(1);
    }

    function payoff(
        Token.Storage storage nuggft,
        uint256 genesis,
        uint256 tokenId
    ) internal {
        require(address(this) == nuggft._ownerOf(tokenId), 'LOAN:P:0');

        uint256 loanData = nuggft._loans[tokenId];

        require(loanData.account() == uint160(msg.sender), 'LOAN:P:1');

        uint256 epoch = genesis.activeEpoch();

        // require(loanData.epoch() < epoch, 'LOAN:L:2');

        require(msg.value >= payoffAmount(nuggft), 'LOAN:P:2');

        delete nuggft._loans[tokenId];

        emit Payoff(tokenId, msg.sender, msg.value);

        nuggft.checkedTransferFromSelf(msg.sender, tokenId);

        nuggft.addStakedSharesAndEth(1, msg.value);
    }

    function liquidate(
        Token.Storage storage nuggft,
        uint256 genesis,
        uint256 tokenId
    ) internal {
        require(address(this) == nuggft._ownerOf(tokenId), 'LOAN:L:0');

        uint256 loanData = nuggft._loans[tokenId];

        require(loanData != 0, 'LOAN:L:1');

        uint256 epoch = genesis.activeEpoch();

        require(loanData.epoch() + LIQUIDATION_PERIOD < epoch, 'LOAN:L:2');

        uint256 minOffer = nuggft.getActiveEthPerShare();

        require(msg.value >= minOffer, 'LOAN:L:3');

        delete nuggft._loans[tokenId];

        emit Liquidate(tokenId, msg.sender, msg.value);

        nuggft.checkedTransferFromSelf(msg.sender, tokenId);

        nuggft.addStakedSharesAndEth(1, msg.value);
    }

    function payoffAmount(Token.Storage storage nuggft) internal view returns (uint256 res) {
        // 1% interest on top of the floor increase
        res = nuggft.getActiveEthPerShare().mulDiv(10100, 10000);
    }
}
