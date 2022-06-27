// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "../../NuggftV1.test.sol";

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

    function test__multioffer__8() public {
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

        uint24 select = 0;

        uint24[] memory nuggs = getAllNuggs();
        for (uint256 i = 0; i < nuggs.length; i++) {
            uint256 _proof = nuggft.proofOf(nuggs[i]);
            if (
                uint16(_proof >> 0x90) == item && //
                nuggs[i] != token1780M &&
                nuggft.agency(nuggs[i]) == 0 &&
                nuggs[i] != nuggft.epoch()
            ) {
                select = nuggs[i];
                break;
            }
        }

        assert(select != 0);

        uint96 v1 = nuggft.vfo(users.frank, token1780M);
        uint96 v2 = nuggft.vfo(token42M, token1780M, item);
        forge.vm.deal(users.frank, v1 + v2);

        forge.vm.startPrank(users.frank);
        nuggft.offer{value: v1 + v2}(token42M, token1780M, item, v1, v2);
        forge.vm.stopPrank();
        // expect.sell().from(users.frank).err(0xA3).exec(token1780M, item, 3 ether);

        expect.offer().from(users.dee).exec{value: nuggft.vfo(token2G, token1780M, item)}(token2G, token1780M, item);
        // expect.sell().from(users.frank).err(0xA3).exec(token1780M, item, 3 ether);

        jumpUp(1);

        v1 = nuggft.vfo(users.dee, select);
        v2 = nuggft.vfo(token2G, select, item);
        forge.vm.deal(users.frank, v1 + v2);
        forge.vm.startPrank(users.dee);
        nuggft.offer{value: v1 + v2}(token2G, select, item, v1, v2);
        forge.vm.stopPrank();
    }
}
