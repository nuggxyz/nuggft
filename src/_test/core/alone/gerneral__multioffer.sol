// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

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
}
