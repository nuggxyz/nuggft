// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

abstract contract revert__loan__0xA1 is NuggftV1Test {
    function test__revert__loan__0xA1__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.mac).err(0xA1).exec(lib.sarr160(500));
    }

    function test__revert__loan__0xA1__pass__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));
    }
}
