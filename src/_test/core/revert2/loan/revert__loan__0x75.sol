// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__loan__0x75 is NuggftV1Test {
    uint160 private token1 = mintable(0);

    function test__revert__loan__0x75__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(token1);

        expect.sell().from(users.frank).exec(token1, 2 ether);

        expect.offer().from(ds.noFallback).value(nuggft.vfo(ds.noFallback, token1)).exec(token1);

        jumpSwap();

        expect.claim().from(ds.noFallback).exec(lib.sarr160(token1), lib.sarrAddress(ds.noFallback));

        expect.loan().from(ds.noFallback).exec(lib.sarr160(token1));
    }

    function test__revert__loan__0x75__pass__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(token1);

        expect.sell().from(users.frank).exec(token1, 2 ether);

        expect.offer().from(ds.hasFallback).value(nuggft.vfo(ds.hasFallback, token1)).exec(token1);

        jumpSwap();

        expect.claim().from(ds.hasFallback).exec(lib.sarr160(token1), lib.sarrAddress(ds.hasFallback));

        expect.loan().from(ds.hasFallback).exec(lib.sarr160(token1));
    }
}
