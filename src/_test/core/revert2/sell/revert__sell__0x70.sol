// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

import '../../../NuggftV1.test.sol';

contract revert__sell__0x70 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__sell__0x70__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        uint96 value = nuggft.eps() - 10 gwei;

        expect.sell().from(users.frank).err(0x70).exec(500, value);
    }

    function test__revert__sell__0x70__pass__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        uint96 value = nuggft.eps();

        expect.sell().from(users.frank).exec(500, value);
    }
}
