// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "forge-std/Script.sol";

contract Script__a is Script {
	function run() public {
		bytes4 sig = "symb";
		assembly {
			mstore(0x00, sig)
			log1(0x00, 0x20, 0x00)
			mstore8(4, 0x12)
			log1(0x00, 0x20, 0x00)

			revert(0x00, 5)
		}
	}
}
