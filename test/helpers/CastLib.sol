// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

library CastLib {
	function to160(uint256 x) internal pure returns (uint24 y) {
		require(x <= type(uint24).max);
		y = uint24(x);
	}

	function to96(uint256 x) internal pure returns (uint96 y) {
		require(x <= type(uint96).max);
		y = uint96(x);
	}

	function to64(uint256 x) internal pure returns (uint64 y) {
		require(x <= type(uint64).max);
		y = uint64(x);
	}

	function to32(uint256 x) internal pure returns (uint32 y) {
		require(x <= type(uint32).max);
		y = uint32(x);
	}

	function to24(uint256 x) internal pure returns (uint24 y) {
		require(x <= type(uint24).max);
		y = uint24(x);
	}

	function to16(uint256 x) internal pure returns (uint16 y) {
		require(x <= type(uint16).max);
		y = uint16(x);
	}

	function to8(uint256 x) internal pure returns (uint8 y) {
		require(x <= type(uint8).max);
		y = uint8(x);
	}
}
