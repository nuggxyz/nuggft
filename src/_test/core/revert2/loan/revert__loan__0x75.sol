// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import "../../../NuggftV1.test.sol";

abstract contract revert__loan__0x75 is NuggftV1Test {
    function test__revert__loan__0x75__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.sell().from(users.frank).exec(500, 2 ether);

        expect.offer().from(ds.noFallback).value(nuggft.vfo(ds.noFallback, 500)).exec(500);

        jump(3002);

        expect.claim().from(ds.noFallback).exec(lib.sarr160(500), lib.sarrAddress(ds.noFallback));

        expect.loan().from(ds.noFallback).exec(lib.sarr160(500));
    }

    function test__revert__loan__0x75__pass__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.sell().from(users.frank).exec(500, 2 ether);

        expect.offer().from(ds.hasFallback).value(nuggft.vfo(ds.hasFallback, 500)).exec(500);

        jump(3002);

        expect.claim().from(ds.hasFallback).exec(lib.sarr160(500), lib.sarrAddress(ds.hasFallback));

        expect.loan().from(ds.hasFallback).exec(lib.sarr160(500));
    }
}
