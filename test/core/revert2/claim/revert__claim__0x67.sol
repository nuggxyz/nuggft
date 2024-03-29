// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__claim__0x67 is NuggftV1Test {
	uint24 private TOKEN_FOR_SALE;

	modifier revert__claim__0x67_setUp() {
		TOKEN_FOR_SALE = mintable(0);
		jumpStart();

		mintHelper(TOKEN_FOR_SALE, users.frank, 1 ether);

		expect.sell().from(users.frank).exec(TOKEN_FOR_SALE, 2 ether);

		jumpSwap();
		_;
	}

	function test__revert__claim__0x67__pass__mintingToken__winnerClaimingAfterSwapIsOver() public revert__claim__0x67_setUp globalDs {
		uint24 tokenId = nuggft.epoch();

		expect.offer().from(users.dee).exec{value: nuggft.msp()}(tokenId);

		jumpSwap();

		expect.claim().from(users.dee).exec(array.b24(tokenId), lib.sarrAddress(users.dee));
	}

	function test__revert__claim__0x67__fail__mintingToken__winnerClaimingDuringMintEpoch() public revert__claim__0x67_setUp globalDs {
		uint24 tokenId = nuggft.epoch();

		expect.globalFrom(users.dee);

		expect.offer().g().exec{value: nuggft.msp()}(tokenId);

		expect.claim().err(0x67).g().exec(array.b24(tokenId), lib.sarrAddress(users.dee));
	}

	function test__revert__claim__0x67__fail__sellingToken__winnerClaimingDuringInitialEpoch() public revert__claim__0x67_setUp globalDs {
		expect.globalFrom(users.dee);

		expect.offer().g().exec{value: nuggft.vfo(users.dee, TOKEN_FOR_SALE)}(TOKEN_FOR_SALE);

		expect.claim().err(0x67).g().exec(array.b24(TOKEN_FOR_SALE), lib.sarrAddress(users.dee));
	}

	function test__revert__claim__0x67__fail__sellingToken__winnerClaimingDuringFinalEpoch() public revert__claim__0x67_setUp globalDs {
		expect.globalFrom(users.dee);

		expect.offer().g().exec{value: nuggft.vfo(users.dee, TOKEN_FOR_SALE)}(TOKEN_FOR_SALE);

		uint24 finalEpoch = getAgencyEpoch(nuggft.agency(TOKEN_FOR_SALE));

		jump(finalEpoch);

		expect.claim().err(0x67).g().exec(array.b24(TOKEN_FOR_SALE), lib.sarrAddress(users.dee));
	}

	function test__revert__claim__0x67__pass__sellingToken__winnerClaimingAfterSwapIsOver() public revert__claim__0x67_setUp globalDs {
		expect.globalFrom(users.dee);

		expect.offer().g().exec{value: nuggft.vfo(users.dee, TOKEN_FOR_SALE)}(TOKEN_FOR_SALE);

		uint24 finalEpoch = getAgencyEpoch(nuggft.agency(TOKEN_FOR_SALE));

		jump(finalEpoch + 1);

		expect.claim().g().exec(array.b24(TOKEN_FOR_SALE), lib.sarrAddress(users.dee));
	}
}
