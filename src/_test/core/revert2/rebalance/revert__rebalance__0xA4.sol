// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__rebalance__0xA4 is NuggftV1Test {
    uint160 private TOKEN1 = mintable(0);
    uint160 private TOKEN2 = mintable(1);

    function test__revert__rebalance__0xA4__fail__desc() public {
        jumpStart();
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(lib.sarr160(TOKEN1));

        expect.mint().from(users.frank).value(2 ether).exec(TOKEN2);

        jumpLoanDown(1);

        expect.rebalance().from(users.mac).value(nuggft.vfr(lib.sarr160(TOKEN1))[0]).err(0xA4).exec(lib.sarr160(TOKEN1));
    }

    function test__revert__rebalance__0xA4__pass__desc() public {
        jumpStart();
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(lib.sarr160(TOKEN1));

        expect.mint().from(users.frank).value(2 ether).exec(TOKEN2);

        jumpLoan(); // liquidation period is 1024 epochs

        expect.rebalance().from(users.mac).value(nuggft.vfr(lib.sarr160(TOKEN1))[0]).exec(lib.sarr160(TOKEN1));
    }

    function test__revert__rebalance__0xA4__pass__donate() public {
        jumpStart();
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(lib.sarr160(TOKEN1));

        expect.mint().from(users.frank).value(2 ether).exec(TOKEN2);

        jumpLoan(); // liquidation period is 1024 epochs

        forge.vm.deal(ds.noFallback, 10000 ether);

        expect.rebalance().from(ds.noFallback).value(nuggft.vfr(lib.sarr160(TOKEN1))[0]).exec(lib.sarr160(TOKEN1));
    }
}
