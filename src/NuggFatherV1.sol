// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import {NuggftV1} from "@nuggft-v1-core/src/NuggftV1.sol";

import {DotnuggV1} from "@dotnugg-v1-core/src/DotnuggV1.sol";

contract NuggFatherV1 {
	NuggftV1 public nuggft;

	constructor(bytes32 salt) payable {
		nuggft = new NuggftV1{value: msg.value, salt: salt}(type(DotnuggV1).creationCode);
	}
}
