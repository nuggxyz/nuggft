// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__mint__0x66 is NuggftV1Test {
    function test__revert__mint__0x66__fail__desc() public {
        forge.vm.startPrank(users.safe);
        {
            forge.vm.expectRevert(hex"7e863b48_66");
            nuggft.trustedMint(mintable(0), users.frank);
            forge.vm.expectRevert(hex"7e863b48_66");
            nuggft.trustedMint(OFFSET, users.frank);
            forge.vm.expectRevert(hex"7e863b48_66");
            nuggft.trustedMint(0, users.frank);
        }
        forge.vm.stopPrank();
    }

    function test__revert__mint__0x66__pass__desc() public {
        forge.vm.startPrank(users.safe);
        {
            nuggft.trustedMint(1, users.frank);
            nuggft.trustedMint(mintable(0) - 1, users.frank);
        }
        forge.vm.stopPrank();
    }
}
