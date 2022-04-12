// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__sell__0x97 is NuggftV1Test {
    function test__revert__sell__0x97__fail__desc() public {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        expect.sell().from(users.dee).err(0x97).exec(tokenId, itemId, floor);
    }

    function test__revert__sell__0x97__pass__desc() public {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        expect.claim().from(users.dee).exec(tokenId, tokenId, itemId);

        expect.sell().from(users.dee).exec(tokenId, itemId, floor);
    }
}
