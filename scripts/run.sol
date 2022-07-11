// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "forge-std/Script.sol";

// import {gas} from "@nuggft-v1-core/test/utils/gas.sol";

contract Script__a is Script {
	function run() public returns (bool) {
		int256 a = int256((type(int96).max) * -1);
		int256 b = int256((type(int96).max));

		console.log("optimizer = false");
		console.log("-----------------------------------------------");
		uint256 left1 = gasleft();
		bool t1 = checkSameSign1(a, b);
		left1 = left1 - gasleft();

		console2.log("iszero(xor(sa, sb)):                  ", left1, t1);

		left1 = gasleft();
		bool t2 = checkSameSign2(a, b);
		left1 = left1 - gasleft();

		console2.log("iszero(xor(shr(255, a), shr(255, b))):", left1, t2);

		left1 = gasleft();
		bool t3 = checkSameSign3(a, b);
		left1 = left1 - gasleft();

		console2.log("eq(shr(255, a), shr(255, b)):         ", left1, t3);

		left1 = gasleft();
		bool t4 = checkSameSign4(a, b);
		left1 = left1 - gasleft();

		console2.log("iszero(shr(255, xor(b, a))):          ", left1, t4);

		left1 = gasleft();
		bool t5 = checkSameSign5(a, b);
		left1 = left1 - gasleft();

		console2.log("sgt(div(a, b), 0):                    ", left1, t5);

		assert(t1 == t2 && t2 == t3 && t3 == t4 && t4 == t5);

		return (t1 == t2 && t2 == t3 && t3 == t4 && t4 == t5);
	}

	function checkSameSign1(int256 a, int256 b) internal pure returns (bool sameSign) {
		uint256 sa;
		uint256 sb;
		assembly {
			sa := sgt(a, sub(0, 1))
			sb := sgt(b, sub(0, 1))
			sameSign := iszero(xor(sa, sb))
		}
	}

	function checkSameSign2(int256 a, int256 b) internal pure returns (bool sameSign) {
		assembly {
			sameSign := iszero(xor(shr(255, a), shr(255, b)))
		}
	}

	function checkSameSign3(int256 a, int256 b) internal pure returns (bool sameSign) {
		assembly {
			sameSign := eq(shr(255, a), shr(255, b))
		}
	}

	function checkSameSign4(int256 a, int256 b) internal pure returns (bool sameSign) {
		assembly {
			sameSign := iszero(shr(255, xor(b, a)))
		}
	}

	function checkSameSign5(int256 a, int256 b) internal pure returns (bool sameSign) {
		assembly {
			sameSign := sgt(div(a, b), 0)
		}
	}
}
