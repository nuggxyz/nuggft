// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

contract general__multioffer is NuggftV1Test {
	function setUp() public {
		reset();
	}

	function test__multioffer__1() public {
		(uint24 first, uint24 last) = nuggft.premintTokens();

		forge.vm.startPrank(users.frank);

		forge.vm.deal(users.frank, 12 ether);

		uint24 tokenA = first + 10;
		uint24 tokenB = first + 11;

		nuggft.offer{value: 1 ether}(tokenA);

		jumpSwap();

		uint256 proof = nuggft.proofOf(tokenB);

		uint16 item = uint16(proof >> 0x90);

		nuggft.check(tokenA, tokenB, item);
		nuggft.check(users.frank, tokenB);

		nuggft.offer{value: 10 ether}(tokenA, tokenB, item, 5 ether, 5 ether);
	}

	function test__multioffer__2() public {
		(uint24 first, uint24 last) = nuggft.premintTokens();

		forge.vm.startPrank(users.frank);

		forge.vm.deal(users.frank, 5 ether);

		uint24 tokenA = first + 10;
		uint24 tokenB = first + 11;

		nuggft.offer{value: 2 ether}(tokenA);

		jumpSwap();

		uint256 proof = nuggft.proofOf(tokenB);

		uint16 item = uint16(proof >> 0x90);

		uint24[] memory a = new uint24[](1);
		a[0] = tokenA;

		address[] memory b = new address[](1);
		b[0] = users.frank;

		nuggft.claim(a, b, new uint24[](1), new uint16[](1));

		nuggft.check(tokenA, tokenB, item);

		nuggft.offer{value: 2 ether}(tokenA, tokenB, item, 1 ether, 1 ether);
	}

	function test__multioffer__3() public {
		(uint24 first, uint24 last) = nuggft.premintTokens();

		forge.vm.startPrank(users.frank);

		forge.vm.deal(users.frank, 5 ether);

		uint24 tokenA = first + 10;
		uint24 tokenB = first + 11;

		nuggft.offer{value: 2 ether}(tokenA);

		jumpSwap();

		uint256 proof = nuggft.proofOf(tokenB);

		uint16 item = uint16(proof >> 0x90);

		uint24[] memory a = new uint24[](1);
		a[0] = tokenA;

		address[] memory b = new address[](1);
		b[0] = users.frank;

		nuggft.claim(a, b, new uint24[](1), new uint16[](1));

		nuggft.check(address(0), tokenB);

		nuggft.offer{value: 1 ether}(tokenB);

		nuggft.check(tokenA, tokenB, item);

		nuggft.offer{value: 1 ether}(tokenA, tokenB, item, 0 ether, 1 ether);
	}

	function test__multioffer__4() public {
		(uint24 first, uint24 last) = nuggft.premintTokens();

		forge.vm.startPrank(users.frank);

		forge.vm.deal(users.frank, 5 ether);

		uint24 tokenA = first + 10;
		uint24 tokenB = first + 11;

		nuggft.offer{value: 2 ether}(tokenA);

		jumpSwap();

		uint256 proof = nuggft.proofOf(tokenB);

		uint16 item = uint16(proof >> 0x90);

		nuggft.offer{value: 1 ether}(tokenB);

		nuggft.check(tokenA, tokenB, item);

		nuggft.offer{value: 1 ether}(tokenA, tokenB, item, 0 ether, 1 ether);
	}

	function test__multioffer__5() public {
		(uint24 first, uint24 last) = nuggft.premintTokens();

		forge.vm.startPrank(users.frank);

		forge.vm.deal(users.frank, 5 ether);
		forge.vm.deal(users.dee, 5 ether);

		uint24 tokenA = first + 10;
		uint24 tokenB = first + 11;

		nuggft.offer{value: 2 ether}(tokenA);

		jumpSwap();

		uint256 proof = nuggft.proofOf(tokenB);

		uint16 item = uint16(proof >> 0x90);

		forge.vm.stopPrank();

		forge.vm.startPrank(users.dee);

		forge.vm.expectRevert(encodeRevert(0x74));
		nuggft.offer{value: 2 ether}(tokenA, tokenB, item, 1 ether, 1 ether);

		forge.vm.stopPrank();
	}

	function test__multioffer__6() public {
		(uint24 first, uint24 last) = nuggft.premintTokens();

		forge.vm.startPrank(users.frank);

		forge.vm.deal(users.frank, 5 ether);
		forge.vm.deal(users.dee, 5 ether);

		uint24 tokenA = first + 10;
		uint24 tokenB = first + 11;

		nuggft.offer{value: 2 ether}(tokenA);

		uint256 proof = nuggft.proofOf(tokenB);

		uint16 item = uint16(proof >> 0x90);

		forge.vm.expectRevert(encodeRevert(0x67));
		nuggft.offer{value: 2 ether}(tokenA, tokenB, item, 1 ether, 1 ether);

		forge.vm.stopPrank();
	}

	function test__multioffer__7() public {
		(uint24 first, uint24 last) = nuggft.premintTokens();
		uint24 token2G = first + 10;
		uint24 token42M = first + 11;
		uint24 token1780M = first + 12;

		forge.vm.deal(users.dee, 5 ether);

		mintHelper(token2G, users.dee, nuggft.vfo(users.dee, token2G));
		mintHelper(token42M, users.frank, nuggft.vfo(users.dee, token42M));

		uint256 proof = nuggft.proofOf(token1780M);

		uint16 item = uint16(proof >> 0x90);

		ds.emit_log_named_uint("item 1119 is:", item);

		uint96 v1 = nuggft.vfo(users.frank, token1780M);
		uint96 v2 = nuggft.vfo(token42M, token1780M, item);
		forge.vm.deal(users.frank, v1 + v2);

		forge.vm.startPrank(users.frank);
		nuggft.offer{value: v1 + v2}(token42M, token1780M, item, v1, v2);
		forge.vm.stopPrank();
		// expect.sell().from(users.frank).err(0xA3).exec(token1780M, item, 3 ether);

		expect.offer().from(users.dee).exec{value: nuggft.vfo(token2G, token1780M, item)}(token2G, token1780M, item);
		// expect.sell().from(users.frank).err(0xA3).exec(token1780M, item, 3 ether);

		jumpSwap();

		expect.claim().from(users.frank).exec(token1780M, users.frank);

		expect.sell().from(users.frank).err(0xB3).exec(token1780M, item, 3 ether);
	}

	function setupWeirdSituation() internal returns (uint24 a, uint24 b, uint24 c) {
		(uint24 first, uint24 last) = nuggft.premintTokens();

		uint24 token2G = first + 10;
		uint24 token42M = first + 11;

		uint16[] memory abc = getAllItems();

		uint16 itm = 0;

		for (uint16 i = 100; i < abc.length; i++) {
			if (findCountOfNewNuggWithItem(abc[i], 0) > 1) {
				itm = abc[i];
				break;
			}
		}

		if (itm == 0) {
			revert("no item found");
		}

		while (uint16(nuggft.proofOf(token2G) >> 0x90) == itm) {
			token2G++;
		}

		while (uint16(nuggft.proofOf(token42M) >> 0x90) == itm) {
			token42M++;
		}

		uint24 token1780M = findNewNuggWithItem2(itm, 0);

		return (token2G, token42M, token1780M);
	}

	function test__multioffer__8() public {
		(uint24 token2G, uint24 token42M, uint24 token1780M) = setupWeirdSituation();

		forge.vm.deal(users.dee, 5 ether);

		mintHelper(token2G, users.dee, nuggft.vfo(users.dee, token2G));
		mintHelper(token42M, users.frank, nuggft.vfo(users.dee, token42M));

		uint256 proof = nuggft.proofOf(token1780M);

		uint16 item = uint16(proof >> 0x90);

		ds.emit_log_named_uint("item 1119 is:", item);

		uint24 select = findNewNuggWithItem2(item, token1780M);

		uint96 v1 = nuggft.vfo(users.frank, token1780M);
		uint96 v2 = nuggft.vfo(token42M, token1780M, item);
		forge.vm.deal(users.frank, v1 + v2);

		forge.vm.startPrank(users.frank);
		nuggft.offer{value: v1 + v2}(token42M, token1780M, item, v1, v2);
		forge.vm.stopPrank();
		// expect.sell().from(users.frank).err(0xA3).exec(token1780M, item, 3 ether);

		expect.offer().from(users.dee).exec{value: nuggft.vfo(token2G, token1780M, item)}(token2G, token1780M, item);
		// expect.sell().from(users.frank).err(0xA3).exec(token1780M, item, 3 ether);

		jumpSwap();

		v1 = nuggft.vfo(users.dee, select);
		v2 = nuggft.vfo(token2G, select, item);
		forge.vm.deal(users.frank, v1 + v2);
		forge.vm.startPrank(users.dee);
		nuggft.offer{value: v1 + v2}(token2G, select, item, v1, v2);
		forge.vm.stopPrank();
	}

	function test__multioffer__9() public {
		(uint24 token2G, uint24 token42M, uint24 token1780M) = setupWeirdSituation();

		forge.vm.deal(users.dee, 5 ether);

		mintHelper(token2G, users.dee, nuggft.vfo(users.dee, token2G));
		mintHelper(token42M, users.frank, nuggft.vfo(users.dee, token42M));

		uint256 proof = nuggft.proofOf(token1780M);

		uint16 item = uint16(proof >> 0x90);

		ds.emit_log_named_uint("item 1119 is:", item);

		uint24 select = findNewNuggWithItem(item, token1780M);

		uint96 v1 = nuggft.vfo(users.frank, token1780M);
		uint96 v2 = nuggft.vfo(token42M, token1780M, item);
		forge.vm.deal(users.frank, v1 + v2);

		forge.vm.startPrank(users.frank);
		nuggft.offer{value: v1 + v2}(token42M, token1780M, item, v1, v2);
		forge.vm.stopPrank();
		// expect.sell().from(users.frank).err(0xA3).exec(token1780M, item, 3 ether);

		expect.offer().from(users.dee).exec{value: nuggft.vfo(token2G, token1780M, item)}(token2G, token1780M, item);
		// expect.sell().from(users.frank).err(0xA3).exec(token1780M, item, 3 ether);

		v1 = nuggft.vfo(users.dee, select);
		v2 = nuggft.vfo(token2G, select, item);
		forge.vm.deal(users.dee, v1 + v2);
		forge.vm.startPrank(users.dee);

		forge.vm.expectRevert(encodeRevert(0xAC));
		nuggft.offer{value: v1 + v2}(token2G, select, item, v1, v2);

		if (SALE_LEN > 1) {
			jumpUp(1);

			forge.vm.expectRevert(encodeRevert(0xB4));
			nuggft.offer{value: v1 + v2}(token2G, select, item, v1, v2);
		}

		if (SALE_LEN > 1) {
			jumpUp(SALE_LEN - 1);
		} else {
			jumpUp(1);
		}
		// forge.vm.expectRevert(encodeRevert(0xB4));
		// nuggft.offer{value: v1 + v2}(token2G, select, item, v1, v2);

		nuggft.offer{value: v1 + v2}(token2G, select, item, v1, v2);

		forge.vm.stopPrank();
	}
}
