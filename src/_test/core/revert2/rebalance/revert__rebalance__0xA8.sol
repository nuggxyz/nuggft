// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

contract revert__rebalance__0xA8 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__rebalance__0xA8__fail__desc() public {
        expect.mint().from(users.frank).value(20 ether).exec(500);

        expect.rebalance().from(users.frank).value(30 ether).err(0xA8).exec(lib.sarr160(500));
    }

    function test__revert__rebalance__0xA8__pass__desc() public {
        expect.mint().from(users.frank).value(20 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.rebalance().from(users.frank).value(30 ether).exec(lib.sarr160(500));
    }
}
