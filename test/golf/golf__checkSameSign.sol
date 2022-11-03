// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "../utils/gas.sol";

contract general__NuggftV1Loan {
	function test__checkSameSign(int256 a, int256 b) public {
		gas.run memory one = gas.start("one");
		bool t1 = checkSameSign1(a, b);
		gas.stop(one);

		gas.run memory two = gas.start("two");
		bool t2 = checkSameSign2(a, b);
		gas.stop(two);

		gas.run memory three = gas.start("three");
		bool t3 = checkSameSign3(a, b);
		gas.stop(three);

		gas.run memory four = gas.start("four");
		bool t4 = checkSameSign4(a, b);
		gas.stop(four);

		// gas.run memory five = gas.start("five");
		// bool t5 = checkSameSign5(a, b);
		// gas.stop(five);

		// gas.run memory five = gas.start("five");
		// bool t5 = checkSameSign5(a, b);
		// gas.stop(five);
		console2.log("t1:", t1);
		console2.log("t2:", t2);
		console2.log("t3:", t3);
		console2.log("t4:", t4);
		// console2.log("t5:", t5);

		assert(t1 == t2 && t2 == t3 && t3 == t4);
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

	// function checkSameSign5(int256 a, int256 b) internal pure returns (bool sameSign) {
	// 	assembly {
	// 		sameSign := sgt(mul(a, b), 0)
	// 	}
	// }
}
