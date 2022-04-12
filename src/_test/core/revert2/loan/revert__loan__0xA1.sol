// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__loan__0xA1 is NuggftV1Test {
    uint24 private TOKEN1 = mintable(0);

    function test__revert__loan__0xA1__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.mac).err(0xA1).exec(array.b24(TOKEN1));
    }

    function test__revert__loan__0xA1__pass__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));
    }
}
