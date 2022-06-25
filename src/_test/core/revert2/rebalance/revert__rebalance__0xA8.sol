// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "../../../NuggftV1.test.sol";

abstract contract revert__rebalance__0xA8 is NuggftV1Test {
    function test__revert__rebalance__0xA8__fail__desc() public {
        uint24 TOKEN1 = mintable(0);

        mintHelper(TOKEN1, users.frank, 20 ether);

        expect.rebalance().from(users.frank).value(30 ether).err(0xA8).exec(array.b24(TOKEN1));
    }

    function test__revert__rebalance__0xA8__pass__desc() public {
        uint24 TOKEN1 = mintable(0);

        mintHelper(TOKEN1, users.frank, 20 ether);

        expect.loan().from(users.frank).exec(array.b24(TOKEN1));

        expect.rebalance().from(users.frank).value(30 ether).exec(array.b24(TOKEN1));
    }
}
