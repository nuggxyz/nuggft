// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../NuggftV1.test.sol";

import "../../_deployment/NuggFatherV1.sol";

contract deployment__NuggFatherV1 is NuggftV1Test {
    function test__deployment__NuggFatherV1__constructor__1() public {
        address dub6ix = 0xfb24279ca9eFC26146D6458bbc19FA4d29315524;
        // private: 75807422351f1bb13f627dca88ed8b465e38d3eaeb7dee595ba1fae3c93e40a8
        // public:  0xfb24279ca9eFC26146D6458bbc19FA4d29315524
        // nugg father proxy 1: 0x63bd444960c11fae19fa66a912c5c910cc606b08
        // nugg father proxy 2: 0xd5de73ca720894630a0c6b36adfac47407943ceb
        // nugg father:         0x1c85b259fa09b71e1e83f5739a4480b42c4b18ad
        // export INIT_CODE_HASH=0x5aeb4c9d93f11ba17adc1e4ddc81cde5f92cd424aad117ddcd63637276423d6f
        // export CALLER=0x362fe7e5a462b962a02d2209245d33cee0841319
        // export FACTORY=0xd5de73ca720894630a0c6b36adfac47407943ceb
        // Computed Address: 0x70d8a7fd182ebb0feae2d67c17eaf97589f7c186
        forge.vm.deal(address(this), 6 ether);

        payable(dub6ix).transfer(3 ether);

        forge.vm.startPrank(dub6ix);
        // NuggFatherV1 father = new NuggFatherV1();
        NuggFatherV1 father = new NuggFatherV1();

        // ds.emit_log_address(address(father.nuggft()));

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
