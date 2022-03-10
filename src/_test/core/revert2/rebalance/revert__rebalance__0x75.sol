// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import "../../../NuggftV1.test.sol";

abstract contract revert__rebalance__0x75 is NuggftV1Test {
    function test__revert__rebalance__0x75__pass__noFallback() public {
        jump(3000);
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.mint().from(users.frank).value(2 ether).exec(501);

        jump(3999);

        expect.rebalance().from(ds.noFallback).value(nuggft.vfr(lib.sarr160(500))[0]).err(0xA4).exec(lib.sarr160(500));
    }

    function test__revert__rebalance__0x75__pass__fallback() public {
        jump(3000);
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.mint().from(users.frank).value(2 ether).exec(501);

        jump(4026); // liquidation period is 1024 epochs

        expect.rebalance().from(ds.hasFallback).value(nuggft.vfr(lib.sarr160(500))[0]).exec(lib.sarr160(500));
    }
}
