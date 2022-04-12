// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__mint__0x71 is NuggftV1Test {
    uint24 private TOKEN1 = mintable(0);
    uint24 private TOKEN2 = mintable(1);

    function test__revert__mint__0x71__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.mint().from(users.frank).err(0x71).exec(TOKEN2);
    }

    function test__revert__mint__0x71__pass__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.mint().from(users.frank).value(nuggft.msp()).exec(TOKEN2);
    }
}
