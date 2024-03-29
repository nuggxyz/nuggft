pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

import {CastLib} from "../../helpers/CastLib.sol";

abstract contract logic__CastLib is NuggftV1Test {
	function safe__to24__a(uint256 x) public pure returns (uint24 y) {
		require(x <= type(uint24).max);
		y = uint24(x);
	}

	function safe__to24__b(uint256 x) public pure returns (uint24 y) {
		assembly {
			if gt(x, 0xffffff) {
				revert(0x00, 0x00)
			}
			y := x
		}
	}

	function test__logic__CastLib__gas__safe__to24__a() public view trackGas {
		safe__to24__a(type(uint24).max);
	}

	function test__logic__CastLib__gas__safe__to24__b() public view trackGas {
		safe__to24__b(type(uint24).max);
	}

	function test__logic__CastLib__gas__to24() public view trackGas {
		CastLib.to24(type(uint24).max);
	}

	function test__logic__CastLib__symbolic__to24(uint24 x) public trackGas {
		uint24 a = safe__to24__a(x);
		uint24 real = CastLib.to24(x);

		console.log(a, real);

		assertEq(a, real, "A");
	}
}
// 49048
// 49036
