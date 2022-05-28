// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;

import "../../../NuggftV1.test.sol";

abstract contract revert__offer__0xA0 is NuggftV1Test {
    function test__revert__offer__0xA0__fail__desc() public {
        uint24 tokenId = nuggft.epoch();
        expect.offer().from(users.frank).value(1 ether).exec(tokenId);

        jumpSwap();

        expect.claim().from(users.frank).exec(tokenId, users.frank);

        expect.loan().from(users.frank).exec(array.b24(tokenId));

        expect.offer().from(users.frank).value(1 ether).err(0xA0).exec(tokenId);
    }

    function test__revert__offer__0xA0__fail__65() public {
        uint24 tokenId = nuggft.epoch();

        jumpSwap();

        expect.offer().from(users.frank).value(1 ether).err(0x65).exec(tokenId);
    }

    function test__revert__offer__0xA0__pass__desc() public {
        uint24 tokenId = nuggft.epoch();

        // jump(tokenId);

        expect.offer().from(users.frank).value(1 ether).exec(tokenId);
    }
}
