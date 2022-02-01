// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

import '../../../NuggftV1.test.sol';

contract revert__mint__0x66 is NuggftV1Test {
    function setUp() public {
        reset__revert();
    }

    function test__revert__mint__0x66__fail__desc() public {
        forge.vm.startPrank(users.safe);
        {
            forge.vm.expectRevert(hex'66');
            nuggft.trustedMint(500, users.frank);

            forge.vm.expectRevert(hex'66');
            nuggft.trustedMint(0, users.frank);
        }
        forge.vm.stopPrank();
    }

    function test__revert__mint__0x66__pass__desc() public {
        forge.vm.startPrank(users.safe);
        {
            nuggft.trustedMint(1, users.frank);
            nuggft.trustedMint(499, users.frank);
        }
        forge.vm.stopPrank();
    }
}
