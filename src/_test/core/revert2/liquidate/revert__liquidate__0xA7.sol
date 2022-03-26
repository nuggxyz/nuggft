// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__liquidate__0xA7 is NuggftV1Test {
    uint160 private TOKEN1 = mintable(0);

    function test__revert__liquidate__0xA7__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(lib.sarr160(TOKEN1));

        uint96[] memory value = nuggft.vfl(lib.sarr160(TOKEN1));

        expect.liquidate().from(users.frank).value(value[0] - 1 gwei).err(0xA7).exec(TOKEN1);
    }

    function test__revert__liquidate__0xA7__pass__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        expect.loan().from(users.frank).exec(lib.sarr160(TOKEN1));

        uint96[] memory value = nuggft.vfl(lib.sarr160(TOKEN1));

        expect.liquidate().from(users.frank).value(value[0]).exec(TOKEN1);
    }
}
