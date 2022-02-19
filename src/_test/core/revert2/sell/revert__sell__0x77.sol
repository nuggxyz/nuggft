// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

abstract contract revert__sell__0x77 is NuggftV1Test {
    function test__revert__sell__0x77__fail__desc() public {
        // mint
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.sell().from(users.frank).exec(500, 2 ether);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, 500)).exec(500);

        expect.sell().from(users.dee).err(0x77).exec(500, 3 ether);

        // bid

        jump(3000);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, 3000)).exec(3000);

        expect.sell().from(users.dee).err(0x77).exec(3000, 3.5 ether);

        jump(3001);

        expect.sell().from(users.dee).err(0x77).exec(3000, 3.5 ether);
    }

    function test__revert__sell__0x77__pass__desc() public {
        jump(3000);
        // mint
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.sell().from(users.frank).exec(500, 2 ether);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, 500)).exec(500);

        jump(3002);

        expect.claim().from(users.dee).exec(lib.sarr160(500), lib.sarrAddress(users.dee));

        expect.sell().from(users.dee).exec(500, 3 ether);

        // bid

        jump(3003);

        expect.offer().from(users.dee).value(3.2 ether).exec(3003);

        jump(3004);

        expect.claim().from(users.dee).exec(lib.sarr160(3003), lib.sarrAddress(users.dee));

        expect.sell().from(users.dee).exec(3003, 3.5 ether);
    }
}
