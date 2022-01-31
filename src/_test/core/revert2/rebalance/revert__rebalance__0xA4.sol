// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

import '../../../NuggftV1.test.sol';

contract revert__rebalance__0xA4 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__rebalance__0xA4__fail__desc() public {
        jump(3000);
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.mint().from(users.frank).value(2 ether).exec(501);

        jump(3999);

        expect.rebalance().from(users.mac).value(nuggft.vfr(lib.sarr160(500))[0]).err(0xA4).exec(lib.sarr160(500));
    }

    function test__revert__rebalance__0xA4__pass__desc() public {
        jump(3000);
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.mint().from(users.frank).value(2 ether).exec(501);

        jump(4001);

        expect.rebalance().from(users.mac).value(nuggft.vfr(lib.sarr160(500))[0]).exec(lib.sarr160(500));
    }
}
