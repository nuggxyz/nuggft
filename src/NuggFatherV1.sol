// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import {NuggftV1} from "@nuggft-v1-core/src/NuggftV1.sol";

import {DotnuggV1, DotnuggV1Light} from "@dotnugg-v1-core/src/DotnuggV1.sol";
import {whoa} from "@dotnugg-v1-core/src/nuggs.data.sol";

contract NuggFatherV1 {
	NuggftV1 public nuggft;

	constructor(bytes32 salt) payable {
		nuggft = new NuggftV1{value: msg.value, salt: salt}(type(DotnuggV1).creationCode);
	}
}

contract NuggFatherV1PartA {
	DotnuggV1Light public dotnugg;

	constructor() {
		dotnugg = new DotnuggV1Light();
	}
}

contract NuggFatherV1PartB {
	constructor(DotnuggV1Light dotnugg) {
		dotnugg.lightWrite(abi.decode(whoa.data, (bytes[])));
	}
}

contract NuggFatherV1PartC {
	NuggftV1 public nuggft;

	constructor(bytes32 salt, address dotnugg) payable {
		nuggft = new NuggftV1{value: msg.value, salt: salt}(abi.encodePacked(dotnugg));
	}
}
