// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__liquidate__0xA6 is NuggftV1Test {
	uint24 private TOKEN1;

	function test__revert__liquidate__0xA6__fail__desc() public {
		TOKEN1 = mintable(0);
		mintHelper(TOKEN1, users.frank, 1 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		expect.liquidate().from(users.mac).value(1.1 ether).err(0xA6).exec(TOKEN1);
	}

	function test__revert__liquidate__0xA6__pass__desc() public {
		TOKEN1 = mintable(0);

		mintHelper(TOKEN1, users.frank, 1 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		expect.liquidate().from(users.frank).value(1.1 ether).exec(TOKEN1);
	}

	function test__revert__liquidate__0xA6__pass__noFallback() public {
		TOKEN1 = mintable(0);

		mintHelper(TOKEN1, ds.noFallback, 1 ether);

		expect.loan().from(ds.noFallback).exec(array.b24(TOKEN1));

		expect.liquidate().from(ds.noFallback).value(1.1 ether).exec(TOKEN1);
	}

	function test__revert__liquidate__0xA6__pass__hasFallback() public {
		TOKEN1 = mintable(0);

		mintHelper(TOKEN1, ds.hasFallback, 1 ether);

		expect.loan().from(ds.hasFallback).exec(array.b24(TOKEN1));

		expect.liquidate().from(ds.hasFallback).value(1.1 ether).exec(TOKEN1);
	}

	function test__revert__liquidate__0xA6__fail__noFallback() public {
		TOKEN1 = mintable(0);

		mintHelper(TOKEN1, users.frank, 1 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		expect.liquidate().from(ds.noFallback).value(1.1 ether).err(0xA6).exec(TOKEN1);
	}
}
