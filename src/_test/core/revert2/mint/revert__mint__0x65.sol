// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__mint__0x65 is NuggftV1Test {
    function test__revert__mint__0x65__fail__desc() public {
        expect.mint().from(users.frank).err(0x65).exec(mintable(0) - 1);

        expect.mint().from(users.frank).err(0x65).exec(MAX_TOKENS + 1);
    }

    function test__revert__mint__0x65__pass__desc() public {
        expect.mint().from(users.frank).exec(mintable(0));

        expect.mint().from(users.frank).exec(OFFSET - 1);
    }
}
