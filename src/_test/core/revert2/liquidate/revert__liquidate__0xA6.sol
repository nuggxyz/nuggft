// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import "../../../NuggftV1.test.sol";

abstract contract revert__liquidate__0xA6 is NuggftV1Test {
    function test__revert__liquidate__0xA6__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.liquidate().from(users.mac).value(1.1 ether).err(0xA6).exec(500);
    }

    function test__revert__liquidate__0xA6__pass__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.liquidate().from(users.frank).value(1.1 ether).exec(500);
    }

    function test__revert__liquidate__0xA6__pass__noFallback() public {
        expect.mint().from(ds.noFallback).value(1 ether).exec(500);

        expect.loan().from(ds.noFallback).exec(lib.sarr160(500));

        expect.liquidate().from(ds.noFallback).value(1.1 ether).exec(500);
    }

    function test__revert__liquidate__0xA6__pass__hasFallback() public {
        expect.mint().from(ds.hasFallback).value(1 ether).exec(500);

        expect.loan().from(ds.hasFallback).exec(lib.sarr160(500));

        expect.liquidate().from(ds.hasFallback).value(1.1 ether).exec(500);
    }

    function test__revert__liquidate__0xA6__fail__noFallback() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.liquidate().from(ds.noFallback).value(1.1 ether).err(0xA6).exec(500);
    }
}
