// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";
import {NuggftV1Proof} from "../../../core/NuggftV1Proof.sol";
import {fragments} from "./fragments.t.sol";

abstract contract system__NuggftV1Loan is NuggftV1Test, fragments {
    uint160 private TOKEN1 = mintable(1);

    function test__system__loan__revert__0xA4__autoLiquidateCantRebalance() public {
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);
        jumpStart();

        expect.loan().from(users.frank).exec(lib.sarr160(TOKEN1));

        expect.rebalance().from(users.mac).value(nuggft.vfr(lib.sarr160(TOKEN1))[0]).err(0xA4).exec(lib.sarr160(TOKEN1));

        jumpLoan();

        expect.rebalance().from(users.mac).value(nuggft.vfr(lib.sarr160(TOKEN1))[0]).exec(lib.sarr160(TOKEN1));
    }

    function test__system__loan__rebalanceFactory() public {
        //jumpStart();
        expect.globalFrom(users.frank);

        expect.mint().g().value(1 ether).exec(TOKEN1);

        expect.loan().g().exec(lib.sarr160(TOKEN1));
        for (uint16 i = 0; i < 50; i++) {
            jumpUp(1);

            expect.rebalance().g().value(lib.asum(nuggft.vfr(lib.sarr160(TOKEN1)))).exec(lib.sarr160(TOKEN1));

            expect.mint().g().value(nuggft.msp()).exec(mintable(i + 100));
        }
    }

    function test__system__loan__friendsRebalanceFactory() public {
        jumpStart();

        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(lib.sarr160(TOKEN1));

        jumpLoan();

        expect.rebalance().from(users.dee).value(lib.asum(nuggft.vfr(lib.sarr160(TOKEN1)))).exec(lib.sarr160(TOKEN1));

        jumpLoan();

        expect.rebalance().from(users.mac).value(lib.asum(nuggft.vfr(lib.sarr160(TOKEN1)))).exec(lib.sarr160(TOKEN1));

        expect.liquidate().from(users.frank).value(lib.asum(nuggft.vfl(lib.sarr160(TOKEN1)))).exec(TOKEN1);
    }

    function test__system__loan__nuggHeritage() public {
        jumpStart();

        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(lib.sarr160(TOKEN1));

        jumpLoan();

        expect.liquidate().from(users.mac).value(lib.asum(nuggft.vfl(lib.sarr160(TOKEN1)))).exec(TOKEN1);

        expect.loan().from(users.mac).exec(lib.sarr160(TOKEN1));

        jumpLoan();

        expect.liquidate().from(users.charlie).value(lib.asum(nuggft.vfl(lib.sarr160(TOKEN1)))).exec(TOKEN1);

        expect.loan().from(users.charlie).exec(lib.sarr160(TOKEN1));
    }
}
