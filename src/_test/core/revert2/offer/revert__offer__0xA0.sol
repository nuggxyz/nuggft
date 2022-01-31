// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

import '../../../NuggftV1.test.sol';

contract revert__offer__0xA0 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__offer__0xA0__fail__desc() public {
        uint24 tokenId = 3000;

        jump(tokenId + 1);

        expect.offer().from(users.frank).value(1 ether).err(0xA0).exec(tokenId);
    }

    function test__revert__offer__0xA0__pass__desc() public {
        uint24 tokenId = 3000;

        jump(tokenId);

        expect.offer().from(users.frank).value(1 ether).exec(tokenId);
    }
}
