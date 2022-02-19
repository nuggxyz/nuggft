// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

abstract contract revert__offer__0xA4 is NuggftV1Test {
    function test__revert__offer__0xA4__fail__desc() public {
        jump(3000);

        expect.mint().from(users.frank).value(.5 ether).exec(500);

        expect.sell().from(users.frank).exec(500, .5 ether);

        expect.offer().from(users.mac).value(.6 ether).exec(500);

        jump(3002);

        expect.offer().from(users.dee).value(0.8 ether).err(0xA4).exec(500);
    }

    function test__revert__offer__0xA4__pass__desc() public {
        jump(3000);

        expect.mint().from(users.frank).value(.5 ether).exec(500);

        expect.sell().from(users.frank).exec(500, .5 ether);

        expect.offer().from(users.mac).value(.6 ether).exec(500);

        expect.offer().from(users.dee).value(0.8 ether).exec(500);
    }
}
