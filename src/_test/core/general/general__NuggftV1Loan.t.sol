// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';

import {ShiftLib} from '../../../libraries/ShiftLib.sol';
import {NuggftV1Loan} from '../../../core/NuggftV1Loan.sol';
import {NuggftV1Token} from '../../../core/NuggftV1Token.sol';

contract general__NuggftV1Loan is NuggftV1Test {
    uint160 internal constant LOAN_TOKENID = 700;
    uint160 internal constant NUM = 4;

    function setUp() public {
        reset();
    }

    function test__general__NuggftV1Loan__multirebalance() public {
        forge.vm.deal(users.frank, 1000000000 ether);

        forge.vm.startPrank(users.frank);

        nuggft.mint{value: 1 ether}(500);

        uint160[] memory list = new uint160[](NUM);

        for (uint160 i = 0; i < NUM; i++) {
            nuggft.mint{value: nuggft.msp()}(LOAN_TOKENID + i);
            nuggft.loan(lib.sarr160(LOAN_TOKENID + i));
            list[i] = LOAN_TOKENID + i;
        }

        for (uint160 i = NUM; i < NUM * 2; i++) {
            nuggft.mint{value: nuggft.msp()}(LOAN_TOKENID + i);
        }

        forge.vm.roll(block.number + 100);

        nuggft.rebalance{value: nuggft.vfr(lib.sarr160(LOAN_TOKENID))[0] * 1000}(list);
    }

    function test__general__NuggftV1Loan__rebalance() public {
        forge.vm.deal(users.frank, 1000000000 ether);

        forge.vm.startPrank(users.frank);

        nuggft.mint{value: 1 ether}(500);

        uint160[] memory list = new uint160[](NUM);

        for (uint160 i = 0; i < NUM; i++) {
            nuggft.mint{value: nuggft.msp()}(LOAN_TOKENID + i);
            nuggft.loan(lib.sarr160(LOAN_TOKENID + i));
            list[i] = LOAN_TOKENID + i;
        }

        for (uint160 i = NUM; i < NUM * 2; i++) {
            nuggft.mint{value: nuggft.msp()}(LOAN_TOKENID + i);
        }

        forge.vm.roll(block.number + 100);

        for (uint160 i = 0; i < NUM; i++) {
            nuggft.rebalance{value: nuggft.vfr(lib.sarr160(LOAN_TOKENID + i))[0]}(lib.sarr160(LOAN_TOKENID + i));
        }
    }
}
