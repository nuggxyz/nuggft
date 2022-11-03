// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import {NuggftV1} from "@nuggft-v1-core/src/NuggftV1.sol";

contract NuggFatherV1 {
	NuggftV1 public nuggft;

	constructor(bytes32 salt) payable {
		nuggft = new NuggftV1{value: msg.value, salt: salt}();
	}
}

// contract NuggFatherV1PartA {
// 	DotnuggV1Light public dotnugg;

// 	constructor() {
// 		dotnugg = new DotnuggV1Light();
// 	}
// }

// contract NuggFatherV1PartB {
// 	constructor(DotnuggV1Light dotnugg) {
// 		dotnugg.lightWrite(abi.decode(whoa.data, (bytes[])));
// 	}
// }

// contract NuggFatherV1PartAB {
// 	DotnuggV1Light public dotnugg;

// 	constructor() {
// 		if (uint160(address(dotnugg)) == 0) revert(DotnuggV1Lib.toString(gasleft()));

// 		dotnugg = new DotnuggV1Light();

// 		dotnugg.lightWrite(abi.decode(whoa.data, (bytes[])));
// 	}
// }

// contract NuggFatherV1PartC {
// 	NuggftV1 public nuggft;

// 	constructor(address dotnugg) payable {
// 		nuggft = new NuggftV1{value: msg.value}(abi.encodePacked(dotnugg));
// 	}
// }

// contract Generic {
// 	constructor() {}
// }
