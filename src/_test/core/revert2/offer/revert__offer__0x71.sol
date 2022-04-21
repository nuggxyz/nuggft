// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__offer__0x71 is NuggftV1Test {
    function test__revert__offer__0x71__fail__desc() public {
        uint24 TOKEN1 = mintable(0);

        jumpStart();

        uint24 tokenId = nuggft.epoch();

        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        // jump(tokenId);

        uint96 msp = nuggft.msp();

        expect.offer().from(users.frank).value(msp - 10 gwei).err(0x71).exec(tokenId);
    }

    function test__revert__offer__0x71__pass__desc() public {
        uint24 TOKEN1 = mintable(0);

        jumpStart();

        uint24 tokenId = nuggft.epoch();

        expect.mint().from(users.frank).value(1 ether).exec(TOKEN1);

        // jump(tokenId);

        uint96 msp = nuggft.msp();

        expect.offer().from(users.frank).value(msp).exec(tokenId);
    }
}
