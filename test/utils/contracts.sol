// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

contract NoFallback {}

contract HasFallback {
	receive() external payable {}

	fallback() external {}
}
