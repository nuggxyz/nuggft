// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";
import {NuggftV1Proof} from "../../../core/NuggftV1Proof.sol";
import {fragments} from "./fragments.t.sol";

abstract contract system__NuggftV1Loan is NuggftV1Test, fragments {
    uint24 private TOKEN1;

    function test__system__loan__revert__0xA4__autoLiquidateCantRebalance() public {
        TOKEN1 = mintable(1);

        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);
        jumpStart();

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));

        expect.rebalance().from(users.mac).value(nuggft.vfr(array.b24(TOKEN1))[0]).err(0xA4).exec(array.b24(TOKEN1));

        jumpLoan();

        expect.rebalance().from(users.mac).value(nuggft.vfr(array.b24(TOKEN1))[0]).exec(array.b24(TOKEN1));
    }

    function test__system__loan__rebalanceFactory() public {
        TOKEN1 = mintable(1);

        //jumpStart();
        expect.globalFrom(users.frank);

        expect.mint().g().value(1 ether).exec(TOKEN1);

        expect.loan().g().exec(array.b24(TOKEN1));
        for (uint16 i = 0; i < 50; i++) {
            jumpUp(1);

            expect.rebalance().g().value(lib.asum(nuggft.vfr(array.b24(TOKEN1)))).exec(array.b24(TOKEN1));

            expect.mint().g().value(nuggft.msp()).exec(mintable(i + 100));
        }
    }

    function test__system__loan__friendsRebalanceFactory() public {
        TOKEN1 = mintable(1);

        jumpStart();

        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));

        jumpLoan();

        expect.rebalance().from(users.dee).value(lib.asum(nuggft.vfr(array.b24(TOKEN1)))).exec(array.b24(TOKEN1));

        jumpLoan();

        expect.rebalance().from(users.mac).value(lib.asum(nuggft.vfr(array.b24(TOKEN1)))).exec(array.b24(TOKEN1));

        expect.liquidate().from(users.frank).value(lib.asum(nuggft.vfl(array.b24(TOKEN1)))).exec(TOKEN1);
    }

    function test__system__loan__nuggHeritage() public {
        TOKEN1 = mintable(1);

        jumpStart();

        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));

        jumpLoan();

        expect.liquidate().from(users.mac).value(lib.asum(nuggft.vfl(array.b24(TOKEN1)))).exec(TOKEN1);

        expect.loan().from(users.mac).exec(array.b24(TOKEN1));

        jumpLoan();

        expect.liquidate().from(users.charlie).value(lib.asum(nuggft.vfl(array.b24(TOKEN1)))).exec(TOKEN1);

        expect.loan().from(users.charlie).exec(array.b24(TOKEN1));
    }
}
