// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__claim__0x76 is NuggftV1Test {
	function test__revert__claim__0x76__fail__desc() public {
		jumpStart();
		uint24 tokenId = nuggft.epoch();

		expect.offer().from(users.frank).exec{value: nuggft.msp()}(tokenId);

		expect.offer().from(users.dee).exec{value: 43 ether}(tokenId);

		jumpSwap();

		expect.claim().from(users.frank).err(0x76).exec(array.b24(tokenId), array.bAddress(users.frank, users.dee));
	}

	function test__revert__claim__0x76__pass__desc() public {
		jumpStart();
		uint24 tokenId = nuggft.epoch();

		expect.offer().from(users.frank).exec{value: nuggft.msp()}(tokenId);

		expect.offer().from(users.dee).exec{value: 43 ether}(tokenId);

		jumpSwap();
		expect.claim().from(users.frank).exec(array.b24(tokenId), array.bAddress(users.frank));
	}

	function test__revert__claim__0x76__pass__noFallback() public {
		jumpStart();
		uint24 tokenId = nuggft.epoch();

		expect.offer().from(ds.noFallback).exec{value: 22 ether}(tokenId);

		expect.offer().from(users.dee).exec{value: 43 ether}(tokenId);

		jumpSwap();
		expect.claim().from(ds.noFallback).exec(array.b24(tokenId), array.bAddress(ds.noFallback));
	}

	function test__revert__claim__0x76__pass__hasFallback() public {
		jumpStart();
		uint24 tokenId = nuggft.epoch();

		expect.offer().from(ds.hasFallback).exec{value: 22 ether}(tokenId);

		expect.offer().from(users.dee).exec{value: 43 ether}(tokenId);

		jumpSwap();
		expect.claim().from(ds.hasFallback).exec(array.b24(tokenId), array.bAddress(ds.hasFallback));
	}
}
