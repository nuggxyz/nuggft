// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

import '../../../NuggftV1.test.sol';

contract revert__offer__0xA3 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__offer__0xA3__fail__desc() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        expect.mint().from(users.charlie).value(1.1 ether).exec(1234);

        expect.sell().from(users.charlie).exec(1234, 1.2 ether);

        expect.offer().from(users.mac).value(1.3 ether).exec(1234);

        uint96 value = floor + 1 ether;

        expect.offer().err(0xA3).from(users.mac).exec{value: value}(1234, tokenId, itemId);
    }

    function test__revert__offer__0xA3__pass__desc() public {
        jump(3000);

        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        expect.mint().from(users.charlie).value(1.1 ether).exec(1234);

        expect.sell().from(users.charlie).exec(1234, 1.2 ether);

        expect.offer().from(users.mac).value(1.3 ether).exec(1234);

        jump(3003);

        expect.claim().from(users.mac).exec(lib.sarr160(1234), lib.sarrAddress(users.mac));

        uint96 value = floor + 1 ether;

        expect.offer().from(users.mac).exec{value: value}(1234, tokenId, itemId);
    }
}
