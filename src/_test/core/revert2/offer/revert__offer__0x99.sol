// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

abstract contract revert__offer__0x99 is NuggftV1Test {
    function test__revert__offer__0x99__fail__desc__claimBeforeOffer() public {
        uint24 epoch = 3000;

        expect.mint().from(users.mac).value(1 ether).exec(500);

        jump(epoch);

        expect.sell().from(users.mac).exec(500, 1.5 ether);

        expect.offer().from(users.frank).value(nuggft.vfo(users.frank, 500)).exec(500);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, 500)).exec(500);

        jump(epoch + 2);

        expect.claim().from(users.dee).exec(lib.sarr160(500), lib.sarrAddress(users.dee));
        jump(epoch + 3);

        expect.sell().from(users.dee).exec(500, 2 ether);

        expect.offer().from(users.frank).value(2.2 ether).err(0x99).exec(500);
    }

    function test__revert__offer__0x99__fail__desc__claimOnOwnSwap() public {
        uint24 epoch = 3000;

        expect.mint().from(users.mac).value(1 ether).exec(500);

        jump(epoch);

        expect.sell().from(users.mac).exec(500, 1.5 ether);

        expect.offer().from(users.mac).value(2.2 ether).err(0x99).exec(500);
    }

    function test__revert__offer__0x99__pass__desc__claimBeforeOffer() public {
        uint24 epoch = 3000;

        expect.mint().from(users.mac).value(1 ether).exec(500);

        jump(epoch);

        expect.sell().from(users.mac).exec(500, 1.5 ether);

        expect.offer().from(users.frank).value(nuggft.vfo(users.frank, 500)).exec(500);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, 500)).exec(500);

        jump(epoch + 2);

        expect.claim().from(users.dee).exec(lib.sarr160(500), lib.sarrAddress(users.dee));
        jump(epoch + 3);

        expect.sell().from(users.dee).exec(500, 2 ether);

        expect.claim().from(users.frank).exec(lib.sarr160(500), lib.sarrAddress(users.frank));

        expect.offer().from(users.frank).value(2.2 ether).exec(500);
    }

    function test__revert__offer__0x99__pass__desc__claimOnOwnSwap() public {
        uint24 epoch = 3000;

        expect.mint().from(users.mac).value(1 ether).exec(500);

        jump(epoch);

        expect.sell().from(users.mac).exec(500, 1.5 ether);

        expect.offer().from(users.frank).value(1.7 ether).exec(500);

        expect.offer().from(users.mac).value(2.2 ether).exec(500);
    }
}
