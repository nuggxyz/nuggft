// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

abstract contract revert__offer__0x68 is NuggftV1Test {
    function test__revert__offer__0x68__fail__desc() public {
        uint24 tokenId = 3000;

        jump(tokenId);

        expect.offer().from(users.frank).value(uint96(nuggft.external__LOSS())).err(0x68).exec(tokenId);
    }

    function test__revert__offer__0x68__pass__desc() public {
        uint24 tokenId = 3000;
        jump(tokenId);

        expect.offer().from(users.frank).value(uint96(nuggft.external__LOSS() + 10 gwei)).exec(tokenId);
    }
}
