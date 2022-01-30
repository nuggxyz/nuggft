// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';
import {fragments} from './fragments.t.sol';

contract system__NuggftV1Loan is NuggftV1Test, fragments {
    function setUp() public {
        reset();
        forge.vm.roll(1000);
    }

    function test__system__loan__revert__0x3b__autoLiquidateCantRebalance() public {
        userMints(users.frank, 500);
        jump(3000);
        forge.vm.startPrank(users.frank);
        {
            nuggft.loan(lib.sarr160(500));
            jump(4000);
            uint96[] memory val = nuggft.vfr(lib.sarr160(500));
            forge.vm.prank(users.mac);
            forge.vm.expectRevert(hex'3b');
            nuggft.rebalance{value: 1 ether}(lib.sarr160(500));
        }
        forge.vm.stopPrank();
    }

    function test__system__loan__rebalanceFactory() public {
        userMints(users.frank, 500);

        forge.vm.startPrank(users.frank);
        {
            nuggft.loan(lib.sarr160(500));
            for (uint16 i = 0; i < 50; i++) {
                jump(3000 + i);
                uint96[] memory vals = nuggft.vfr(lib.sarr160(500));
                nuggft.rebalance{value: vals[0]}(lib.sarr160(500));
                userMints(users.frank, 501 + i);
            }
        }
        forge.vm.stopPrank();
    }
}
