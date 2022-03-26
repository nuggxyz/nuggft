// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__loan__0x77 is NuggftV1Test {
    uint160 private token1 = mintable(0);

    function test__revert__loan__0x77__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(token1);

        expect.sell().from(users.frank).exec(token1, 2 ether);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, token1)).exec(token1);

        expect.loan().from(users.dee).err(0x77).exec(lib.sarr160(token1));

        jumpStart();

        uint160 token2 = nuggft.epoch();

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, token2)).exec(token2);

        expect.loan().from(users.dee).err(0x77).exec(lib.sarr160(token2));

        jumpUp(1);

        expect.loan().from(users.dee).err(0x77).exec(lib.sarr160(token2));
    }

    function test__revert__loan__0x77__pass__desc() public {
        jumpStart();

        expect.mint().from(users.frank).value(1 ether).exec(token1);

        expect.sell().from(users.frank).exec(token1, 2 ether);

        expect.offer().from(users.dee).value(nuggft.vfo(users.dee, token1)).exec(token1);

        jumpSwap();
        jumpUp(1);

        expect.claim().from(users.dee).exec(lib.sarr160(token1), lib.sarrAddress(users.dee));

        expect.loan().from(users.dee).exec(lib.sarr160(token1));

        // bid

        uint160 token2 = nuggft.epoch();

        expect.offer().from(users.dee).value(3.2 ether).exec(token2);

        jumpSwap();

        expect.claim().from(users.dee).exec(lib.sarr160(token2), lib.sarrAddress(users.dee));

        expect.loan().from(users.dee).exec(lib.sarr160(token2));
    }
}
