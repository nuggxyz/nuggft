// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__sell__0xA9 is NuggftV1Test {
    uint160 private TOKEN1 = mintable(0);

    function test__revert__sell__0xA9__fail__desc() public {
        jumpStart();

        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        expect.mint().from(users.mac).value(.00001 ether).exec(TOKEN1);

        expect.sell().from(users.dee).exec(encItemIdClaim(tokenId, itemId), .1 ether);

        expect.offer().from(users.mac).value(.3 ether).exec(encItemId(TOKEN1, tokenId, itemId));

        jumpSwap();

        expect.claim().from(users.mac).exec(lib.sarr160(encItemIdClaim(tokenId, itemId)), lib.sarrAddress(address(TOKEN1)));

        expect.sell().from(users.dee).err(0xA9).exec(encItemIdClaim(tokenId, itemId), .1 ether);
    }

    function test__revert__sell__0xA9__pass__desc() public {
        jumpStart();

        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        expect.mint().from(users.mac).value(.00001 ether).exec(TOKEN1);

        expect.sell().from(users.dee).exec(encItemIdClaim(tokenId, itemId), .1 ether);

        expect.offer().from(users.mac).value(.3 ether).exec(encItemId(TOKEN1, tokenId, itemId));

        jumpSwap();

        expect.claim().from(users.mac).exec(lib.sarr160(encItemIdClaim(tokenId, itemId)), lib.sarrAddress(address(TOKEN1)));

        expect.sell().from(users.mac).exec(encItemIdClaim(TOKEN1, itemId), .1 ether);
    }
}
