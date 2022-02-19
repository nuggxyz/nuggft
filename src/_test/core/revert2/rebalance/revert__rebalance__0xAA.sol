// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

abstract contract revert__rebalance__0xAA is NuggftV1Test {
    function test__revert__rebalance__0xAA__fail__desc() public {
        expect.mint().from(users.frank).value(20 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.rebalance().from(users.frank).value(.1 ether).err(0xAA).exec(lib.sarr160(500));
    }

    function test__revert__rebalance__0xAA__pass__desc() public {
        expect.mint().from(users.frank).value(20 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.rebalance().from(users.frank).value(nuggft.vfr(lib.sarr160(500))[0]).exec(lib.sarr160(500));
    }
}
