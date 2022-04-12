// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__rebalance__0xAA is NuggftV1Test {
    uint24 private TOKEN1 = mintable(0);

    function test__revert__rebalance__0xAA__fail__desc() public {
        expect.mint().from(users.frank).value(20 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));

        expect.rebalance().from(users.frank).value(nuggft.vfr(array.b24(TOKEN1))[0] - 1).err(0xAA).exec(array.b24(TOKEN1));
    }

    function test__revert__rebalance__0xAA__pass__desc() public {
        expect.mint().from(users.frank).value(20 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));

        expect.rebalance().from(users.frank).value(nuggft.vfr(array.b24(TOKEN1))[0]).exec(array.b24(TOKEN1));
    }
}
