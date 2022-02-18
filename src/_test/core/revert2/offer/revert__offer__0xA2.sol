// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

contract revert__offer__0xA2 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__offer__0xA2__fail__desc() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        expect.offer().err(0xA2).from(users.mac).exec{value: value}(charliesTokenId, tokenId, itemId);
    }

    function test__revert__offer__0xA2__pass__desc() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        expect.offer().from(users.charlie).exec{value: value}(charliesTokenId, tokenId, itemId);
    }
}
