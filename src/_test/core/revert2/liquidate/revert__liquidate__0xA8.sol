// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__liquidate__0xA8 is NuggftV1Test {
    function test__revert__liquidate__0xA8__fail__desc() public {
        expect.mint().from(users.frank).value(.5 ether).exec(500);

        // expec called debt() which performed this check earlier than desired
        forge.vm.deal(users.frank, 900 ether);
        forge.vm.prank(users.frank);
        forge.vm.expectRevert(hex"7e863b48_A8");
        nuggft.liquidate{value: 1 ether}(500);
    }

    function test__revert__liquidate__0xA8__pass__desc() public {
        expect.mint().from(users.frank).value(.5 ether).exec(500);

        expect.loan().from(users.frank).exec(lib.sarr160(500));

        expect.liquidate().from(users.frank).value(1 ether).exec(500);
    }
}
