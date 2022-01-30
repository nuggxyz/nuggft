// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';
import {fragments} from './fragments.t.sol';

contract system__NuggftV1Loan is NuggftV1Test, fragments {
    function setUp() public {
        reset__system();
    }

    function test__system__loan__revert__0x2F__autoLiquidateCantRebalance() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);
        jump(3000);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.rebalance().from(users.mac).value(nuggft.vfr(lib.sarr160(500))[0]).err(0x3B).exec(lib.sarr160(500));

        jump(5000);

        expect.rebalance().from(users.mac).value(nuggft.vfr(lib.sarr160(500))[0]).exec(lib.sarr160(500));
    }

    function test__system__loan__rebalanceFactory() public {
        // jump(3000);
        expect.globalFrom(users.frank);

        expect.mint().g().value(1 ether).exec(500);

        expect.loan().g().exec(lib.sarr160(500));

        for (uint16 i = 0; i < 50; i++) {
            jump(3001 + i);

            expect.rebalance().g().value(lib.asum(nuggft.vfr(lib.sarr160(500)))).exec(lib.sarr160(500));

            expect.mint().g().value(nuggft.msp()).exec(501 + i);
        }
    }

    function test__system__loan__friendsRebalanceFactory() public {
        jump(3000);

        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        jump(4001);

        expect.rebalance().from(users.dee).value(lib.asum(nuggft.vfr(lib.sarr160(500)))).exec(lib.sarr160(500));

        jump(5002);

        expect.rebalance().from(users.mac).value(lib.asum(nuggft.vfr(lib.sarr160(500)))).exec(lib.sarr160(500));

        expect.liquidate().from(users.frank).value(lib.asum(nuggft.vfl(lib.sarr160(500)))).exec(500);
    }

    function test__system__loan__nuggHeritage() public {
        jump(3000);

        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        jump(4001);

        expect.liquidate().from(users.mac).value(lib.asum(nuggft.vfl(lib.sarr160(500)))).exec(500);

        expect.loan().from(users.mac).exec(lib.sarr160(500));

        jump(5002);

        expect.liquidate().from(users.charlie).value(lib.asum(nuggft.vfl(lib.sarr160(500)))).exec(500);

        expect.loan().from(users.charlie).exec(lib.sarr160(500));
    }
}
