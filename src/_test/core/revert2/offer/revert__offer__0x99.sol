// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;

import "../../../NuggftV1.test.sol";

abstract contract revert__offer__0x99 is NuggftV1Test {
    function test__revert__offer__0x99__fail__desc__claimBeforeOffer() public {
        uint24 token1 = mintable(0);

        mintHelper(token1, users.mac, 1 ether);

        jumpStart();

        expect.sell().from(users.mac).exec(token1, 1.5 ether);

        expect.offer().from(users.frank).value(nuggft.vfo(users.frank, token1)).exec(token1);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, token1)).exec(token1);

        jumpSwap();

        expect.claim().from(users.dee).exec(array.b24(token1), lib.sarrAddress(users.dee));

        jumpUp(1);

        expect.sell().from(users.dee).exec(token1, 2 ether);

        expect.offer().from(users.frank).value(2.2 ether).err(0x99).exec(token1);
    }

    function test__revert__offer__0x99__fail__desc__claimOnOwnSwap() public {
        uint24 token1 = mintable(0);

        mintHelper(token1, users.mac, 1 ether);

        jumpStart();

        expect.sell().from(users.mac).exec(token1, 1.5 ether);

        expect.offer().from(users.mac).value(2.2 ether).err(0x99).exec(token1);
    }

    function test__revert__offer__0x99__pass__desc__claimBeforeOffer() public {
        uint24 token1 = mintable(0);

        mintHelper(token1, users.mac, 1 ether);

        jumpStart();

        expect.sell().from(users.mac).exec(token1, 1.5 ether);

        expect.offer().from(users.frank).value(nuggft.vfo(users.frank, token1)).exec(token1);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, token1)).exec(token1);

        jumpSwap();

        expect.claim().from(users.dee).exec(array.b24(token1), lib.sarrAddress(users.dee));

        jumpUp(1);

        expect.sell().from(users.dee).exec(token1, 2 ether);

        expect.claim().from(users.frank).exec(array.b24(token1), lib.sarrAddress(users.frank));

        expect.offer().from(users.frank).value(2.2 ether).exec(token1);
    }

    function test__revert__offer__0x99__pass__desc__claimOnOwnSwap() public {
        uint24 token1 = mintable(0);

        mintHelper(token1, users.mac, 1 ether);

        jumpStart();

        expect.sell().from(users.mac).exec(token1, 1.5 ether);

        expect.offer().from(users.frank).value(1.7 ether).exec(token1);

        expect.claim().from(users.mac).exec(array.b24(token1), array.bAddress(users.mac));
    }

    // same as above but mac offers again before he claims
    function test__revert__claim__0x67__fail__desc__claimOnOwnSwap() public {
        uint24 token1 = mintable(0);

        mintHelper(token1, users.mac, 1 ether);

        jumpStart();

        expect.sell().from(users.mac).exec(token1, 1.5 ether);

        expect.offer().from(users.frank).value(1.7 ether).exec(token1);

        expect.offer().from(users.mac).value(2.2 ether).exec(token1);

        expect.claim().from(users.mac).err(0x67).exec(array.b24(token1), array.bAddress(users.mac));
    }
}
