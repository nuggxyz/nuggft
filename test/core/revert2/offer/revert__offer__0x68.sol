// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__offer__0x68 is NuggftV1Test {
	function test__revert__offer__0x68__fail__desc() public {
		uint24 tokenId = nuggft.epoch();

		jump(tokenId);

		uint96 ogvfo = nuggft.vfo(users.mac, tokenId);

		expect.offer().from(users.mac).value(uint96(ogvfo)).exec(tokenId);

		expect.offer().from(users.frank).value(uint96(ogvfo + 1)).err(0x72).exec(tokenId);
	}

	// this is the scenario we really care about
	function test__revert__offer__0x68__fail__zerocommit() public {
		uint24 tokenId = nuggft.epoch();

		jump(tokenId);

		expect.offer().from(users.mac).value(uint96(0)).err(0x71).exec(tokenId);

		expect.offer().from(users.frank).value(uint96(0)).err(0x71).exec(tokenId);
	}

	function test__revert__offer__0x68__fail__zerocommit1() public {
		uint24 tokenId = nuggft.epoch();

		jump(tokenId);

		expect.offer().from(users.mac).value(nuggft.vfo(users.mac, tokenId)).exec(tokenId);

		expect.offer().from(users.frank).value(uint96(0)).err(0x68).exec(tokenId);
	}

	function test__revert__offer__0x68__pass__nonmint2() public {
		uint24 tokenId = nuggft.epoch();

		jump(tokenId);

		expect.offer().from(users.mac).value(nuggft.vfo(users.mac, tokenId)).exec(tokenId);

		expect.offer().from(users.frank).value(nuggft.vfo(users.frank, tokenId)).exec(tokenId);
	}

	function test__revert__offer__0x68__fail__nocommit3() public {
		uint24 tokenId = nuggft.epoch();

		jump(tokenId);

		expect.offer().from(users.mac).value(nuggft.vfo(users.mac, tokenId)).exec(tokenId);

		// subtract 1 for when the "round up" is nothing
		expect.offer().from(users.frank).value((((nuggft.vfo(users.frank, tokenId) - 1) / LOSS) * LOSS) - 1).err(0x72).exec(tokenId);
	}

	function test__revert__offer__0x68__pass__desc() public {
		uint24 tokenId = nuggft.epoch();
		jump(tokenId);

		expect.offer().from(users.frank).value(uint96(nuggft.vfo(users.frank, tokenId))).exec(tokenId);
	}

	function test__revert__offer__0x68__pass__onmint() public {
		uint24 tokenId = nuggft.epoch();

		jump(tokenId);

		expect.offer().from(users.frank).value(nuggft.vfo(users.frank, tokenId)).exec(tokenId);
	}
}
