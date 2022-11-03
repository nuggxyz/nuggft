//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../utils/forge.sol";

import "./base.sol";

contract expectBalance is base {
	struct Snapshot {
		address user;
		int192 expected;
		uint256 start;
	}

	Snapshot[] snapshots;

	function clear() public {
		delete snapshots;
	}

	function bal(address user) public view returns (uint96) {
		return uint96(user.balance);
	}

	function start(
		address user,
		uint96 value,
		bool up
	) public {
		uint96 balan = this.bal(user);
		if (!up && value > balan) {
			ds.emit_log_named_uint("value:   ", value);
			ds.emit_log_named_uint("balance: ", balan);
			ds.assertTrue(
				false,
				'EXPECT:BALANCE: DOWN value is greater than balance, it will overflow - make sure you are calling "deal" before starting the expect'
			);
		}

		snapshots.push(
			Snapshot({
				user: user, //
				expected: cast.i192(up ? balan + value : balan - value),
				start: balan
			})
		);
	}

	function stop() public {
		for (uint256 i = 0; i < snapshots.length; i++) {
			this.bal(snapshots[i].user);
			ds.assertBalance(snapshots[i].user, snapshots[i].expected, "stopExpectBalance ");
		}
		this.clear();
	}

	function rollback() public {
		for (uint256 i = 0; i < snapshots.length; i++) {
			ds.assertBalance(snapshots[i].user, snapshots[i].start, "rollbackExpectBalance ");
		}
		this.clear();
	}
}
