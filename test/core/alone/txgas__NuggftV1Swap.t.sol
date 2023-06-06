// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

contract txgas__NuggftV1Swap is NuggftV1Test {
	uint24 private MINT_TOKENID;
	uint24 private COMMIT_TOKENID;
	uint24 private CARRY_TOKENID;

	uint24 private SELL_TOKENID;
	uint24 private CLAIM_TOKENID;

	function setUp() public {
		reset();

		MINT_TOKENID = mintable(1004);
		COMMIT_TOKENID = mintable(1498);
		CARRY_TOKENID = mintable(1300);

		SELL_TOKENID = mintable(1496);
		CLAIM_TOKENID = mintable(1497);
		forge.vm.deal(users.dee, 40_000 ether);
		mintHelper(COMMIT_TOKENID, users.dee, 100 ether);

		mintHelper(CARRY_TOKENID, users.dee, nuggft.msp());
		forge.vm.startPrank(users.dee);
		nuggft.sell(COMMIT_TOKENID, nuggft.eps() + LOSS * 2);
		nuggft.sell(CARRY_TOKENID, nuggft.eps() + LOSS * 2);

		forge.vm.stopPrank();

		mintHelper(SELL_TOKENID, users.frank, nuggft.msp());

		forge.vm.deal(users.mac, 40_000 ether);
		forge.vm.startPrank(users.mac);
		uint96 val = nuggft.vfo(users.mac, CARRY_TOKENID);
		nuggft.offer{value: val}(CARRY_TOKENID);
		forge.vm.stopPrank();
	}

	function test__txgas__NuggftV1Swap__offer__mint() public {
		nuggft.offer{value: 200 ether}(nuggft.epoch());
	}

	function test__txgas__NuggftV1Swap__offer__commit() public {
		nuggft.offer{value: 200 ether}(COMMIT_TOKENID);
	}

	function test__txgas__NuggftV1Swap__offer__carry() public {
		nuggft.offer{value: 200 ether}(CARRY_TOKENID);
	}

	// function test__txgas__NuggftV1Swap__sell() public {
	//     nuggft.rebalance{value: 200 ether}(REBALANCE_TOKENID);
	// }

	// function test__txgas__NuggftV1Swap__claim() public {
	//     nuggft.liquidate{value: 200 ether}(LIQUIDATE_TOKENID);
	// }
}
