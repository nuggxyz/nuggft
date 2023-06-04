// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

contract NoFallback {}

contract HasFallback {
	receive() external payable {}

	fallback() external {}
}
