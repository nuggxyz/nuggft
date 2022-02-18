// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

contract revert__offer__0x71 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__offer__0x71__fail__desc() public {
        uint24 tokenId = 3000;

        expect.mint().from(users.frank).value(1 ether).exec(500);

        jump(tokenId);

        uint96 msp = nuggft.msp();

        expect.offer().from(users.frank).value(msp - 10 gwei).err(0x71).exec(tokenId);
    }

    function test__revert__offer__0x71__pass__desc() public {
        uint24 tokenId = 3000;

        expect.mint().from(users.frank).value(1 ether).exec(500);

        jump(tokenId);

        uint96 msp = nuggft.msp();

        expect.offer().from(users.frank).value(msp).exec(tokenId);
    }
}
