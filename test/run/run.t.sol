// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

// import "../utils/forge.sol";

contract runner {
	mapping(uint24 => uint256) tokens;

	struct Test {
		uint256 a;
		uint256 b;
		uint256 c;
	}

	function run() external {
		address(new runner2()).call(abi.encodePacked(bytes32(0x0000000000000)));
		// Test storage s;
		address(new runner3()).call(abi.encodePacked(bytes32(0x0000000000000)));

		// // prettier-ignore
		// assembly {
		//     s.slot := 0x4455

		//     // mstore(0x20, 0x4455)

		//     // mstore(0x00, /* 0 == position of "a" in struct */ 0)

		//     // sstore(keccak256(0x00, 0x40), 0xfff0)

		//     // mstore(0x00, /* 1 == position of "b" in struct */ 1)

		//     // sstore(keccak256(0x00, 0x40), 0xfff1)

		//     // mstore(0x00, /* 2 == position of "c" in struct */ 2)

		//     // sstore(keccak256(0x00, 0x40), 0xfff2)
		// }

		// s.a = 0xfff0;
		// s.b = 0xfff1;
		// s.c = 0xfff2;

		// ds.inject.log(s.a);

		// ds.inject.log(s.b);

		// ds.inject.log(s.c);
	}

	fallback() external {
		// check++;
		// ds.emit_log_uint(check);
		// (bool result, ) = address(msg.sender).delegatecall(msg.data);
		// if (result) {
		//     this;
		// }
	}
}

contract runner2 {
	uint256 check = 0;

	fallback() external {
		// check++;
		// ds.emit_log_uint(check);

		(bool result, ) = address(msg.sender).delegatecall(msg.data);

		if (result) {
			this;
		}
	}
}

contract runner3 {
	uint256 check = 0;

	fallback() external {
		(bool result, ) = address(msg.sender).delegatecall(msg.data);

		if (result) {
			check = 1;
		}
	}
}
