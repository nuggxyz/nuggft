// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import '../NuggftV1.test.sol';

import '../../_deployment/NuggFatherV1.sol';

contract deployment__NuggFatherV1 is NuggftV1Test {
    function test__deployment__NuggFatherV1__constructor__1() public {
        address deployer = 0x27b6E7032F3800389D963DDba80CEB6f7815a4FC;
        address dub6ix = 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77;

        forge.vm.deal(address(this), 6 ether);

        payable(deployer).transfer(3 ether);
        payable(dub6ix).transfer(3 ether);

        forge.vm.startPrank(deployer);
        // NuggFatherV1 father = new NuggFatherV1();

        forge.vm.stopPrank();

        forge.vm.startPrank(dub6ix);
        // NuggftV1 nuggft = father.nuggft();

        // Expect e = new Expect(address(nuggft));

        // father.mint{value: 1 ether}(5);
    }
}
