// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {NuggFatherV1} from "../NuggFatherV1.sol";

contract Script__a is Script {
	function run() public {
		new NuggFatherV1{value: 10 ether}(bytes32(0));
	}
}
