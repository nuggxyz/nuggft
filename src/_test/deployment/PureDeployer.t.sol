// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "../NuggftV1.test.sol";

import {NuggftV1Epoch} from "../../core/NuggftV1Epoch.sol";

contract deployment__PureDeployer is NuggftV1Test {
    function setUp() public {}

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [pure] toEpoch
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__deployment__PureDeployer__constructor__1() public {
        address deployer = forge.vm.addr(123456);

        forge.vm.deal(address(this), 3 ether);

        payable(deployer).transfer(3 ether);

        forge.vm.startPrank(deployer);

        string[] memory inputs = new string[](2);
        inputs[0] = "node";

        inputs[1] = "jq '.bin' ../dotnugg-core/out/DotnuggV1.sol/DotnuggV1.json --raw-output";

        // new PureDeployer(0, 0, __nuggft, __dotnugg, __nuggs);
    }
}
