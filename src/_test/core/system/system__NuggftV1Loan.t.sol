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
        expect.mint().exec(
            500,
            lib.txd({
                from: users.frank, //
                value: 1 ether
            })
        );

        expect.loan().exec(
            lib.sarr160(500),
            lib.txd({
                from: users.frank //
            })
        );

        for (uint16 i = 0; i < 50; i++) {
            jump(3000 + i);

            expect.rebalance().exec(
                lib.sarr160(500),
                lib.txd({
                    from: users.frank, //
                    value: lib.asum(nuggft.vfr(lib.sarr160(500)))
                })
            );

            expect.mint().exec(
                501 + i,
                lib.txd({
                    from: users.frank, //
                    value: nuggft.msp()
                })
            );
        }
    }
}
