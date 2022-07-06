//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../utils/forge.sol";
import "../RiggedNuggftV1.sol";

import "../NuggftV1.test.sol";
import "../../interfaces/INuggftV1.sol";
import {IxNuggftV1} from "../../interfaces/IxNuggftV1.sol";
import {NuggftV1Constants} from "../../core/NuggftV1Constants.sol";

abstract contract base is INuggftV1Event, NuggftV1Constants {
	RiggedNuggftV1 nuggft;
	IxNuggftV1 internal xnuggft;

	constructor() {
		nuggft = RiggedNuggftV1(global.getAddressSafe("RiggedNuggft"));
		xnuggft = nuggft.xnuggftv1();
	}
}
