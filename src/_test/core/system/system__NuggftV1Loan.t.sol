// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';
import {fragments} from './fragments.t.sol';

contract system__NuggftV1Loan is NuggftV1Test, fragments {
    // function test__system__loan__autoLiquidate() public {
    //     userMints(users.frank, 500);
    //     jump(3000);
    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.loan(lib.sarr160(500));
    //         // jump(4000);
    //         // uint96[] memory val = nuggft.vfr(lib.sarr160(500));
    //         // forge.vm.prank(users.mac);
    //         // nuggft.rebalance{value: 1 gwei}(lib.sarr160(500));
    //     }
    //     forge.vm.stopPrank();
    // }
}
