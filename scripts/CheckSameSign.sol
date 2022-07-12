// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

function checkSameSign1(int256 a, int256 b) view returns (bool sameSign) {
	uint256 sa;
	uint256 sb;
	assembly {
		sa := sgt(a, sub(0, 1))
		sb := sgt(b, sub(0, 1))
		sameSign := iszero(xor(sa, sb))
	}
}

function checkSameSign2(int256 a, int256 b) view returns (bool sameSign) {
	assembly {
		sameSign := iszero(xor(shr(255, a), shr(255, b)))
	}
}

function checkSameSign3(int256 a, int256 b) view returns (bool sameSign) {
	assembly {
		sameSign := eq(shr(255, a), shr(255, b))
	}
}

function checkSameSign4(int256 a, int256 b) view returns (bool sameSign) {
	assembly {
		sameSign := iszero(shr(255, xor(b, a)))
	}
}

function checkSameSign5(int256 a, int256 b) view returns (bool sameSign) {
	assembly {
		sameSign := lt(xor(a, b), 0x8000000000000000000000000000000000000000000000000000000000000000)
	}
}

function checkSameSign6(int256 a, int256 b) view returns (bool sameSign) {
	assembly {
		sameSign := not(xor(a, b))
	}
}

function execute(int256 a, int256 b) view {
	console2.log("optimizer = false");
	console2.log("-----------------------------------------------");

	uint256 left = gasleft();
	bool t1 = checkSameSign1(a, b);
	left = left - gasleft();

	console2.log("iszero(xor(sa, sb)):                  ", left, t1);

	left = gasleft();
	bool t2 = checkSameSign2(a, b);
	left = left - gasleft();

	console2.log("iszero(xor(shr(255, a), shr(255, b))):", left, t2);

	left = gasleft();
	bool t3 = checkSameSign3(a, b);
	left = left - gasleft();

	console2.log("eq(shr(255, a), shr(255, b)):         ", left, t3);

	left = gasleft();
	bool t4 = checkSameSign4(a, b);
	left = left - gasleft();

	console2.log("iszero(shr(255, xor(b, a))):          ", left, t4);

	left = gasleft();
	bool t5 = checkSameSign5(a, b);
	left = left - gasleft();

	console2.log("lt(xor(a, b), 0x800000...):           ", left, t5);

	left = gasleft();
	bool t6 = checkSameSign6(a, b);
	left = left - gasleft();

	console2.log("lt(xor(a, b), 0x800000...):           ", left, t6);

	assert(t1 == t2 && t2 == t3 && t3 == t4 && t4 == t5 && t5 == t6);
}

// -----------------------------------------------------------------------------
// prerequisites:
// -----------------------------------------------------------------------------

// 1: install foundry

// 2: install forge-std:
// $ forge install foundry-rs/forge-std

// -----------------------------------------------------------------------------
// run fuzz test:
// -----------------------------------------------------------------------------
// forge test -m test__checkSameSign
contract Test__checkSameSign is Test {
	function test__checkSameSign(int256 a, int256 b) public view {
		execute(a, b);
	}
}

// -----------------------------------------------------------------------------
// generate gas output:
// -----------------------------------------------------------------------------
// FOUNDRY_PROFILE="optim-off" forge script ./test/CheckSameSign.sol --tc Script__checkSameSign
// FOUNDRY_PROFILE="optim-on" forge script ./test/CheckSameSign.sol --tc Script__checkSameSign
contract Script__checkSameSign is Script {
	function run() public view {
		execute(int256((type(int96).max) * -1), int256((type(int96).max)));
	}
}
