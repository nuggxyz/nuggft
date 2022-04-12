// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__rebalance__0x75 is NuggftV1Test {
    uint24 private TOKEN1 = mintable(0);
    uint24 private TOKEN2 = mintable(1);

    function test__revert__rebalance__0x75__pass__noFallback() public {
        jumpStart();
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));

        expect.mint().from(users.frank).value(2 ether).exec(TOKEN2);

        jumpLoanDown(1);

        expect.rebalance().from(ds.noFallback).value(nuggft.vfr(array.b24(TOKEN1))[0]).err(0xA4).exec(array.b24(TOKEN1));
    }

    function test__revert__rebalance__0x75__pass__fallback() public {
        jumpStart();
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));

        expect.mint().from(users.frank).value(2 ether).exec(TOKEN2);

        jumpLoan(); // liquidation period is 1024 epochs

        expect.rebalance().from(ds.hasFallback).value(nuggft.vfr(array.b24(TOKEN1))[0]).exec(array.b24(TOKEN1));
    }
}
