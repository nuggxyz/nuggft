// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

import '../../../NuggftV1.test.sol';

contract revert__sell__0xA2 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__sell__0xA2__fail__desc() public {
        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        expect.sell().err(0xA2).from(users.mac).exec(encItemIdClaim(tokenId, itemId), 1 ether);
    }

    function test__revert__sell__0xA2__pass__desc() public {
        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        expect.sell().from(users.dee).exec(encItemIdClaim(tokenId, itemId), 1 ether);
    }
}
