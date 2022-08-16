// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__rebalance__0xA4 is NuggftV1Test {
	function test__revert__rebalance__0xA4__fail__desc() public {
		uint24 TOKEN1 = mintable(0);
		uint24 TOKEN2 = mintable(1);
		mintHelper(TOKEN1, users.frank, 1 ether);

		mintHelper(TOKEN2, users.frank, 2 ether);
		jumpStart();

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		jumpLoanDown(1);

		expect.rebalance().from(users.mac).value(nuggft.vfr(array.b24(TOKEN1))[0]).err(0xA4).exec(array.b24(TOKEN1));
	}

	function test__revert__rebalance__0xA4__pass__desc() public {
		uint24 TOKEN1 = mintable(0);
		uint24 TOKEN2 = mintable(1);
		jumpStart();
		mintHelper(TOKEN1, users.frank, 1 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		mintHelper(TOKEN2, users.frank, 2 ether);

		jumpLoan(); // liquidation period is 1024 epochs

		expect.rebalance().from(users.mac).value(nuggft.vfr(array.b24(TOKEN1))[0]).exec(array.b24(TOKEN1));
	}

	function test__revert__rebalance__0xA4__pass__donate() public {
		uint24 TOKEN1 = mintable(0);
		uint24 TOKEN2 = mintable(1);
		jumpStart();
		mintHelper(TOKEN1, users.frank, 1 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		mintHelper(TOKEN2, users.frank, 2 ether);

		jumpLoan(); // liquidation period is 1024 epochs

		forge.vm.deal(ds.noFallback, 10000 ether);

		expect.rebalance().from(ds.noFallback).value(nuggft.vfr(array.b24(TOKEN1))[0]).exec(array.b24(TOKEN1));
	}
}
