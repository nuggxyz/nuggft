// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import "../NuggftV1.test.sol";

import "../../_deployment/NuggFatherV1.sol";

contract deployment__NuggFatherV1 is NuggftV1Test {
    function test__deployment__NuggFatherV1__constructor__1() public {
        address dub6ix = 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77;

        forge.vm.deal(address(this), 6 ether);

        payable(dub6ix).transfer(3 ether);

        forge.vm.startPrank(dub6ix);
        NuggFatherV1 father = new NuggFatherV1();
        forge.vm.stopPrank();

        // for (uint160 i = 1; i < 10; i++) {
        //     // father.nuggft().floop(i);

        //     // uint8[8] memory list = father.dotnugg().decodeProofCore(father.nuggft().proofOf(i));

        //     // for (uint8 i = 0; i < 8; i++) {
        //     //     father.dotnugg().svg(father.dotnugg().calc(father.dotnugg().read(i, list[i])));
        //     // }

        //     ds.emit_log_string((father.nuggft().imageURI(i)));
        // }
    }
}
