//SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "../utils/forge.sol";

import "@nuggft-v1-core/src/interfaces/INuggftV1.sol";

import {IxNuggftV1} from "@nuggft-v1-core/src/interfaces/IxNuggftV1.sol";
import {NuggftV1Constants} from "@nuggft-v1-core/src/common/NuggftV1Constants.sol";

import "@nuggft-v1-core/test/main.sol";
import "@nuggft-v1-core/test/extend.sol";

abstract contract base is INuggftV1Event, NuggftV1Constants {
	NuggftV1Extended nuggft;
	IxNuggftV1 internal xnuggft;

	constructor() {
		nuggft = NuggftV1Extended(global.getAddressSafe("RiggedNuggft"));
		xnuggft = nuggft.xnuggftv1();
	}
}
