// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../../NuggftV1.test.sol';

import {ShiftLib} from '../../../libraries/ShiftLib.sol';
import {NuggftV1Loan} from '../../../core/NuggftV1Loan.sol';
import {NuggftV1Token} from '../../../core/NuggftV1Token.sol';

contract logic__NuggftV1Loan is NuggftV1Test {
    uint160 internal constant LOAN_TOKENID = 1499;

    constructor() {
        reset();

        forge.vm.deal(users.frank, 1 ether);

        forge.vm.startPrank(users.frank);

        nuggft.mint{value: 1 ether}(LOAN_TOKENID);

        nuggft.loan(LOAN_TOKENID);
    }

    function test__stress__NuggftV1Loan__rebalance() public {
        console.log(nuggft.eps(), nuggft.msp());
        forge.vm.deal(users.frank, 1000000000 ether);

        for (uint256 i = 0; i < 1000; i++) {
            uint96 frankStartBal = uint96(users.frank.balance);

            (, , , , uint24 b_insolventEpoch) = nuggft.loanInfo(LOAN_TOKENID);

            uint160 tokenId = nuggft.epoch();
            (, uint96 nextSwapAmount, uint96 senderCurrentOffer) = nuggft.valueForOffer(users.frank, tokenId);

            uint96 value = nextSwapAmount - senderCurrentOffer;
            forge.vm.startPrank(users.frank);
            nuggft.offer{value: value}(tokenId);

            uint96 valueforRebal = nuggft.valueForRebalance(LOAN_TOKENID);
            forge.vm.startPrank(users.frank);
            nuggft.rebalance{value: valueforRebal}(LOAN_TOKENID);

            (, , , , uint24 a_insolventEpoch) = nuggft.loanInfo(LOAN_TOKENID);

            {
                require(b_insolventEpoch == a_insolventEpoch || b_insolventEpoch == a_insolventEpoch - 1, 'A');
                // console.log(frankStartBal, users.frank.balance);
                require(frankStartBal - value - valueforRebal == users.frank.balance, 'B');
            }

            forge.vm.roll(block.number + 1);
        }
    }
}
//   990090000000000000
//  1009891800000000000
//  1009891800000000000
