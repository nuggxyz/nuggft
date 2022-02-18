// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

import '../../../NuggftV1.test.sol';

contract revert__claim__0xA0 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    // had to rig this one. the checks are too good
    function test__revert__claim__0xA0__fail__desc() public {
        expect.mint().from(users.frank).value(1 ether).exec(500);

        forge.vm.prank(users.frank);
        forge.vm.expectRevert(hex'a0');
        nuggft.claim(lib.sarr160(500), lib.sarrAddress(users.frank));
    }

    function test__revert__claim__0xA0__pass__desc() public {
        uint24 tokenId = 3000;

        jump(tokenId);

        expect.offer().from(users.frank).value(1 ether).exec(tokenId);

        jump(tokenId + 1);

        expect.claim().from(users.frank).exec(lib.sarr160(tokenId), lib.sarrAddress(users.frank));
    }
}
