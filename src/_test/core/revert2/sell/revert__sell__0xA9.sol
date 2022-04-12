// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__sell__0xA9 is NuggftV1Test {
    uint24 private TOKEN1 = mintable(0);

    function test__revert__sell__0xA9__fail__desc() public {
        jumpStart();

        (uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        expect.mint().from(users.mac).value(.00001 ether).exec(TOKEN1);

        expect.sell().from(users.dee).exec(tokenId, itemId, .1 ether);

        expect.offer().from(users.mac).value(.3 ether).exec(TOKEN1, tokenId, itemId);

        jumpSwap();

        expect.claim().from(users.mac).exec(tokenId, TOKEN1, itemId);

        expect.sell().from(users.dee).err(0xA9).exec(tokenId, itemId, .1 ether);
    }

    function test__revert__sell__0xA9__pass__desc() public {
        jumpStart();

        (uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        expect.mint().from(users.mac).value(.00001 ether).exec(TOKEN1);

        expect.sell().from(users.dee).exec(tokenId, itemId, .1 ether);

        expect.offer().from(users.mac).value(.3 ether).exec(TOKEN1, tokenId, itemId);

        jumpSwap();

        expect.claim().from(users.mac).exec(tokenId, TOKEN1, itemId);

        expect.sell().from(users.mac).exec(TOKEN1, itemId, .1 ether);
    }
}
