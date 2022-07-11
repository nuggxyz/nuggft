// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

contract Tmp {
	function checkSameSign(int256 a, int256 b) public pure returns (bool sameSign) {
		// Get the signs of a and b.
		uint256 sa;
		uint256 sb;
		assembly {
			sa := sgt(a, sub(0, 1))
			sb := sgt(b, sub(0, 1))
			sameSign := iszero(xor(sa, sb))
		}
	}

	function checkSameSign2(int256 a, int256 b) public pure returns (bool sameSign) {
		assembly {
			sameSign := iszero(xor(shr(255, a), shr(255, b)))
		}
	}

	function checkSameSign3(int256 a, int256 b) public pure returns (bool sameSign) {
		assembly {
			sameSign := eq(shr(255, a), shr(255, b))
		}
	}
}
