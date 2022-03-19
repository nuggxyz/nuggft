// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__mint__0x65 is NuggftV1Test {
    function test__revert__mint__0x65__fail__desc() public {
        expect.mint().from(users.frank).err(0x65).exec(499);

        expect.mint().from(users.frank).err(0x65).exec(10501);
    }

    function test__revert__mint__0x65__pass__desc() public {
        expect.mint().from(users.frank).exec(500);

        expect.mint().from(users.frank).exec(OFFSET - 1);
    }
}
