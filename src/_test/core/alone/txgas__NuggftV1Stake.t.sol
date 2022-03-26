// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

contract txgas__NuggftV1Stake is NuggftV1Test {
    function setUp() public {
        reset();
        // forge.vm.roll(21000);

        forge.vm.deal(users.frank, 40000 ether);

        forge.vm.startPrank(users.frank);

        nuggft.mint{value: 100 ether}(1199);
        nuggft.mint{value: 100 ether}(1200);

        forge.vm.roll(2400);

        nuggft.mint{value: 100 ether}(1201);
    }

    function test__txgas__NuggftV1Stake__addStakedEth() public {
        nuggft.mint{value: nuggft.msp()}(1202);
    }
}
