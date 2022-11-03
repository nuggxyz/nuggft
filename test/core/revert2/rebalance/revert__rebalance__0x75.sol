// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__rebalance__0x75 is NuggftV1Test {
	function test__revert__rebalance__0x75__pass__noFallback() public {
		uint24 TOKEN1 = mintable(0);
		uint24 TOKEN2 = mintable(1);
		mintHelper(TOKEN1, users.frank, 1 ether);
		mintHelper(TOKEN2, users.frank, 2 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		jumpStart();

		jumpLoanDown(1);

		expect.rebalance().from(ds.noFallback).value(nuggft.vfr(array.b24(TOKEN1))[0]).err(0xA4).exec(array.b24(TOKEN1));
	}

	function test__revert__rebalance__0x75__pass__fallback() public {
		uint24 TOKEN1 = mintable(0);
		uint24 TOKEN2 = mintable(1);
		jumpStart();
		mintHelper(TOKEN1, users.frank, 1 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		mintHelper(TOKEN2, users.frank, 2 ether);

		jumpLoan(); // liquidation period is 1024 epochs

		expect.rebalance().from(ds.hasFallback).value(nuggft.vfr(array.b24(TOKEN1))[0]).exec(array.b24(TOKEN1));
	}
}
