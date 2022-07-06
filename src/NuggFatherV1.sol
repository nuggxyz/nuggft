// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import {NuggftV1} from "./NuggftV1.sol";

contract NuggFatherV1 {
	NuggftV1 public nuggft;

	constructor(bytes32 salt) payable {
		nuggft = new NuggftV1{value: msg.value, salt: salt}();
	}
}
