// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__mint__0x66 is NuggftV1Test {
	// function test__revert__mint__0x66__fail__desc() public {
	//     uint24 a = mintable(0);
	//     uint24 b = trustMintable(0);
	//     forge.vm.startPrank(users.safe);
	//     forge.vm.deal(users.safe, 1000000 ether);
	//     {
	//         uint96 value = nuggft.msp();
	//         forge.vm.expectRevert(hex"7e863b48_66");
	//         nuggft.trustedMint{value: value}(a, users.frank);
	//         value = nuggft.msp();
	//         forge.vm.expectRevert(hex"7e863b48_66");
	//         nuggft.trustedMint{value: value}(a, users.frank);
	//         value = nuggft.msp();
	//         forge.vm.expectRevert(hex"7e863b48_66");
	//         nuggft.trustedMint{value: value}(0, users.frank);
	//         value = nuggft.msp();
	//         forge.vm.expectRevert(hex"7e863b48_66");
	//         nuggft.trustedMint{value: value}(b - 1, users.frank);
	//         value = nuggft.msp();
	//         jumpStart();
	//         uint24 tokenId = nuggft.epoch();
	//         forge.vm.expectRevert(hex"7e863b48_66");
	//         nuggft.trustedMint{value: value}(tokenId, users.frank);
	//     }
	//     forge.vm.stopPrank();
	// }
	// function test__revert__mint__0x66__pass__desc() public {
	//     uint24 a = mintable(0);
	//     uint24 b = trustMintable(0);
	//     forge.vm.startPrank(users.safe);
	//     forge.vm.deal(users.safe, 1000000 ether);
	//     {
	//         nuggft.trustedMint{value: nuggft.msp()}(b, users.frank);
	//         nuggft.trustedMint{value: nuggft.msp()}(a - 1, users.frank);
	//     }
	//     forge.vm.stopPrank();
	// }
}
