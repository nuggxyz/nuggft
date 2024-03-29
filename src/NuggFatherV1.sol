// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import {NuggftV1} from "git.nugg.xyz/nuggft/src/NuggftV1.sol";
import {DotnuggV1} from "git.nugg.xyz/dotnugg/src/DotnuggV1.sol";

contract NuggFatherV1 {
	NuggftV1 public nuggft;

	constructor(bytes32 salt) payable {
		nuggft = new NuggftV1{value: msg.value, salt: salt}(address(0));
	}
}

contract NuggFatherV1Dotnugg {
	DotnuggV1 public dotnugg;

	constructor() {
		dotnugg = new DotnuggV1();
	}
}
