//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "../utils/forge.sol";

import "git.nugg.xyz/nuggft/src/interfaces/INuggftV1.sol";

import {IxNuggftV1} from "git.nugg.xyz/nuggft/src/interfaces/IxNuggftV1.sol";
import {NuggftV1Constants} from "git.nugg.xyz/nuggft/src/common/NuggftV1Constants.sol";

import "git.nugg.xyz/nuggft/test/main.sol";
import "git.nugg.xyz/nuggft/test/extend.sol";

abstract contract base is INuggftV1Event, NuggftV1Constants {
	NuggftV1Extended nuggft;
	IxNuggftV1 internal xnuggft;

	constructor() {
		nuggft = NuggftV1Extended(global.getAddressSafe("RiggedNuggft"));
		xnuggft = nuggft.xnuggftv1();
	}
}
