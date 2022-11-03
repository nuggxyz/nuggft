// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./revert__NuggftV1Epoch.t.sol";
import "./revert__NuggftV1Loan.t.sol";
import "./revert__NuggftV1Stake.t.sol";
import "./revert__NuggftV1Swap.t.sol";

contract Revert is revert__NuggftV1Epoch, revert__NuggftV1Loan, revert__NuggftV1Stake, revert__NuggftV1Swap {
	function setUp() public {
		reset();
	}
}
