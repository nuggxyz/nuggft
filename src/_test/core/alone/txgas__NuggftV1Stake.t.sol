// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

contract txgas__NuggftV1Stake is NuggftV1Test {
    function setUp() public {
        reset();

        forge.vm.deal(users.frank, 40000 ether);

        forge.vm.startPrank(users.frank);

        nuggft.mint{value: 100 ether}(mintable(1199));
        nuggft.mint{value: nuggft.msp()}(mintable(1200));

        jumpStart();

        nuggft.mint{value: nuggft.msp()}(mintable(1201));
    }

    function test__txgas__NuggftV1Stake__addStakedEth() public {
        nuggft.mint{value: nuggft.msp()}(mintable(1202));
    }
}
