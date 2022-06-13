// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;

import "../../../NuggftV1.test.sol";

abstract contract revert__offer__0xA2 is NuggftV1Test {
    function test__revert__offer__0xA2__fail__desc() public {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint24 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        expect.offer().err(0xA2).from(users.mac).exec{value: value}(charliesTokenId, tokenId, itemId);
    }

    function test__revert__offer__0xA2__pass__desc() public {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint24 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        expect.offer().from(users.charlie).exec{value: value}(charliesTokenId, tokenId, itemId);
    }
}
