// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";

contract general__multioffer is NuggftV1Test {
    function setUp() public {
        reset();
    }

    function test__multioffer() public {
        (uint24 first, uint24 last) = nuggft.premintTokens();

        forge.vm.deal(users.frank, 2 ether);

        forge.vm.prank(users.frank);

        nuggft.offer{value: 2 ether}(array.b64(first, first + 1), array.b256(1 ether, 1 ether));

        forge.vm.expectRevert(abi.encodePacked(bytes4(0x7e863b48), bytes1(0xAF)));
        nuggft.offer{value: 1 ether}(array.b64(first + 2, first + 3), array.b256(1 ether, 1 ether));

        forge.vm.expectRevert(abi.encodePacked(bytes4(0x7e863b48), bytes1(0xAF)));
        nuggft.offer{value: 2 ether}(array.b64(first + 2, first + 3), array.b256(1 ether, 1 ether, 1 ether));
    }
}
