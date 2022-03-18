// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__claim__0xA5 is NuggftV1Test {
    function test__revert__claim__0xA5__fail__desc() public {
        jump(OFFSET);

        uint160 tokenId = nuggft.epoch();

        expect.offer().from(users.dee).exec(tokenId);

        jump(OFFSET + 1);

        expect.claim().from(users.frank).err(0xA5).exec(array.b160(tokenId), array.bAddress(users.frank));
    }

    function test__revert__claim__0xA5__pass__desc() public {
        jump(OFFSET);

        uint160 tokenId = nuggft.epoch();

        expect.offer().from(users.dee).exec(tokenId);

        jump(OFFSET + 1);

        expect.claim().from(users.dee).exec(array.b160(tokenId), array.bAddress(users.dee));
    }
}
