// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__offer__0xA0 is NuggftV1Test {
	function test__revert__offer__0xA0__fail__desc() public {
		uint24 tokenId = nuggft.epoch();
		expect.offer().from(users.frank).value(1 ether).exec(tokenId);

		jumpSwap();

		expect.claim().from(users.frank).exec(tokenId, users.frank);

		expect.loan().from(users.frank).exec(array.b24(tokenId));

		expect.offer().from(users.frank).value(1 ether).err(0xA0).exec(tokenId);
	}

	function test__revert__offer__0xA0__fail__65() public {
		uint24 tokenId = nuggft.epoch();

		jumpSwap();

		expect.offer().from(users.frank).value(1 ether).err(0x65).exec(tokenId);
	}

	function test__revert__offer__0xA0__pass__desc() public {
		uint24 tokenId = nuggft.epoch();

		// jump(tokenId);

		expect.offer().from(users.frank).value(1 ether).exec(tokenId);
	}

	function test__revert__offer__0xA0__pass__jumpOne() public {
		if (SALE_LEN > 1) {
			uint24 tokenId = nuggft.epoch();

			jumpUp(1);

			expect.offer().from(users.frank).value(1 ether).exec(tokenId);
		}
	}

	function test__revert__offer__0xA0__pass__jumpOneMinusSaleLen() public {
		if (SALE_LEN > 1) {
			uint24 tokenId = nuggft.epoch();

			jumpUp(SALE_LEN - 1);

			expect.offer().from(users.frank).value(1 ether).exec(tokenId);
		}
	}

	function test__revert__offer__0xA0__pass__jumpOneBidTwice() public {
		if (SALE_LEN > 1) {
			uint24 tokenId = nuggft.epoch();

			jumpUp(1);

			expect.offer().from(users.frank).value(1 ether).exec(tokenId);
			expect.offer().from(users.frank).value(500 ether).exec(tokenId);
		}
	}
}
