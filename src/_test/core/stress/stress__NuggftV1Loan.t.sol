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

    function test__stress__NuggftV1Loan__rebalance2() public {
        forge.vm.deal(users.frank, 1000000000 ether);

        for (uint256 i = 0; i < 1000; i++) {
            uint96 frankStartBal = uint96(users.frank.balance);

            (, , , , , uint24 b_insolventEpoch) = nuggft.debt(LOAN_TOKENID);

            uint160 tokenId = nuggft.epoch();
            (, uint96 nextSwapAmount, uint96 senderCurrentOffer) = nuggft.check(users.frank, tokenId);

            uint96 value = nextSwapAmount - senderCurrentOffer;
            forge.vm.startPrank(users.frank);
            nuggft.offer{value: value}(tokenId);

            (, , , uint96 __fee, uint96 __earn, ) = nuggft.debt(LOAN_TOKENID);

            uint96 valueforRebal = nuggft.vfr(lib.sarr160(LOAN_TOKENID))[0];
            forge.vm.startPrank(users.frank);
            nuggft.rebalance{value: valueforRebal}(lib.sarr160(LOAN_TOKENID));

            (, , , , , uint24 a_insolventEpoch) = nuggft.debt(LOAN_TOKENID);

            {
                require(b_insolventEpoch == a_insolventEpoch || b_insolventEpoch == a_insolventEpoch - 1, 'A');
                // console.log(frankStartBal, users.frank.balance);
                console.log(nuggft.eps(), nuggft.msp());

                require(frankStartBal - value - valueforRebal == users.frank.balance, 'B');
                // require(frankStartBal - value + __earn - __fee == users.frank.balance, 'D');
            }

            forge.vm.roll(block.number + 1);
        }
    }

    function test__stress__NuggftV1Loan__rebalance__multi() public {
        console.log(nuggft.eps(), nuggft.msp());
        forge.vm.deal(users.frank, 1000000000 ether);

        uint160[] memory tokenIds = new uint160[](950);
        forge.vm.startPrank(users.frank);

        for (uint160 i = 500; i < 1450; i++) {
            tokenIds[i - 500] = i;

            nuggft.mint{value: nuggft.msp()}(i);

            nuggft.loan(i);
        }

        // uint96 frankStartBal = uint96(users.frank.balance);

        // (, , , , uint24 b_insolventEpoch) = nuggft.loanInfo(LOAN_TOKENID);

        uint160 tokenId = nuggft.epoch();
        (, uint96 nextSwapAmount, uint96 senderCurrentOffer) = nuggft.check(users.frank, tokenId);

        uint96 value = nextSwapAmount - senderCurrentOffer;
        // forge.vm.startPrank(users.frank);
        nuggft.offer{value: value}(tokenId);

        // uint96 valueforRebal = nuggft.valueForRebalance(LOAN_TOKENID);
        // forge.vm.startPrank(users.frank);
        nuggft.rebalance{value: users.frank.balance}(tokenIds);
    }

    function test__stress__NuggftV1Loan__rebalance__multi__manyAccounts() public {
        console.log(nuggft.eps(), nuggft.msp());
        forge.vm.deal(users.frank, 1000000000 ether);

        uint160[] memory tokenIds = new uint160[](950);

        for (uint160 i = 500; i < 1450; i++) {
            address a = forge.vm.addr(i * 2699);

            forge.vm.startPrank(a);

            tokenIds[i - 500] = i;

            forge.vm.deal(a, nuggft.msp());

            nuggft.mint{value: a.balance}(i);

            nuggft.loan(i);
            forge.vm.stopPrank();
        }

        emit log_named_uint('balance', address(nuggft).balance);

        forge.vm.roll(block.number + 6000);

        // uint96 frankStartBal = uint96(users.frank.balance);

        // (, , , , uint24 b_insolventEpoch) = nuggft.loanInfo(LOAN_TOKENID);

        // uint160 tokenId = nuggft.epoch();
        // (, uint96 nextSwapAmount, uint96 senderCurrentOffer) = nuggft.check(users.frank, tokenId);

        // uint96 value = nextSwapAmount - senderCurrentOffer;
        // // forge.vm.startPrank(users.frank);
        // nuggft.offer{value: value}(tokenId);

        // uint96 valueforRebal = nuggft.valueForRebalance(LOAN_TOKENID);
        forge.vm.startPrank(users.frank);
        nuggft.rebalance(tokenIds);
    }
}
//   990090000000000000
//  1009891800000000000
//  1009891800000000000
