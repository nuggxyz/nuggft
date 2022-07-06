//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../utils/forge.sol";

import "./base.sol";
import "./stake.sol";
import "./balance.sol";
import {Expect} from "./Expect.sol";

contract expectLiquidate is base {
	expectStake stake;
	expectBalance balance;
	Expect creator;

	constructor() {
		stake = new expectStake();
		balance = new expectBalance();
		creator = Expect(msg.sender);
	}

	struct Run {
		uint256 agency;
		address sender;
		uint24 tokenId;
		uint96 eps;
		uint96 msp;
		uint96 principal;
		uint96 fee;
		uint96 earned;
		bool shouldDonate;
	}

	bytes execution;

	function clear() public {
		delete execution;
	}

	lib.txdata prepped;

	function from(address user) public returns (expectLiquidate) {
		prepped.from = user;
		return this;
	}

	function value(uint96 val) public returns (expectLiquidate) {
		prepped.value = val;
		return this;
	}

	function g() public returns (expectLiquidate) {
		prepped.from = creator._globalFrom();
		return this;
	}

	function err(bytes memory b) public returns (expectLiquidate) {
		prepped.err = b;
		return this;
	}

	function err(bytes1 b) public returns (expectLiquidate) {
		if (b != 0x0) prepped.err = abi.encodePacked(bytes4(0x7e863b48), b);
		return this;
	}

	function exec(uint24 tokenId) public payable {
		lib.txdata memory _prepped = prepped;
		_prepped.value += uint96(msg.value);

		delete prepped;
		exec(tokenId, _prepped);
	}

	function exec(uint24 tokenId, lib.txdata memory txdata) public {
		forge.vm.deal(txdata.from, txdata.from.balance + txdata.value);
		this.start(tokenId, txdata.from, txdata.value);
		forge.vm.startPrank(txdata.from);
		if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
		nuggft.liquidate{value: txdata.value}(tokenId);
		forge.vm.stopPrank();
		txdata.err.length > 0 ? this.rollback() : this.stop();
	}

	function start(
		uint24 tokenId,
		address sender,
		uint96 _value
	) public {
		require(execution.length == 0, "EXPECT-LIQUIDATE:START: execution already esists");

		Run memory run;

		run.sender = sender;

		run.eps = nuggft.eps();

		run.msp = nuggft.msp();

		run.tokenId = tokenId;

		run.shouldDonate = ds.noFallback == run.sender;

		run.agency = nuggft.agency(run.tokenId);

		// (, , run.principal, run.fee, run.earned, ) = nuggft.debt(tokenId);

		run.principal = uint96((run.agency << 26) >> 186) * .1 gwei;
		run.fee = run.principal / nuggft.REBALANCE_FEE_BPS();
		run.earned = run.eps - run.principal;

		uint96 change;

		if (run.earned >= run.fee + run.principal) {
			// if more was earned than the fee
			change = run.shouldDonate ? 0 : run.earned - run.fee - run.principal;
			balance.start(run.sender, change, true);
			balance.start(address(nuggft), change, false);
		} else {
			if (run.shouldDonate) {
				change = _value;
			} else {
				change = (run.fee + run.principal) - run.earned;
			}
			balance.start(run.sender, change, false);
			balance.start(address(nuggft), change, true);
		}

		if (run.shouldDonate) {
			stake.start(run.earned + _value - run.principal, 0, true);
		} else {
			stake.start(run.fee, 0, true);
		}

		// if (run.shouldDonate) {
		//     if (run.earned >= run.fee + rebalance) {
		//         balance.start(run.sender, change, true);
		//         balance.start(address(nuggft), change, false);
		//     }
		//     stake.start(run.earned + run.principal, 0, true);
		// } else {
		//     if (run.earned >= run.fee + run.principal) {
		//         // if more was earned than the fee
		//         uint96 change = (run.earned - run.fee) + run.principal;
		//         balance.start(run.sender, change, true);
		//         balance.start(address(nuggft), change, false);
		//     } else {
		//         uint96 change = (run.fee - run.earned) + run.principal;
		//         balance.start(run.sender, change, false);
		//         balance.start(address(nuggft), change, true);
		//     }

		//     stake.start(run.fee, 0, true);
		// }

		execution = abi.encode(run);
	}

	function stop() public {
		require(execution.length > 0, "EXPECT-LIQUIDATE:STOP: execution does not exist");

		Run memory run = abi.decode(execution, (Run));

		uint96 postEps = nuggft.eps();

		uint256 postAgency = nuggft.agency(run.tokenId);

		ds.assertEq(postAgency >> 254, 0x01, "EXPECT-LIQUIDATE:STOP - agency flag should be OWN - 0x01");

		ds.assertEq(address(uint160(postAgency)), run.sender, "EXPECT-LIQUIDATE:STOP - agent should be the sender");

		ds.assertEq(uint96((postAgency << 26) >> 186), 0, "EXPECT-LIQUIDATE:STOP - principal should be zero");

		ds.assertGt(postEps, run.eps, "EXPECT-LIQUIDATE:STOP - eps should be geater than before");

		// @todo - any other checks we want here?

		stake.stop();
		balance.stop();

		this.clear();
	}

	function rollback() public {
		require(execution.length > 0, "EXPECT-LIQUIDATE:ROLLBACK: execution does not exist");

		Run memory run = abi.decode(execution, (Run));

		uint256 preAgency = run.agency;
		uint256 postAgency = nuggft.agency(run.tokenId);

		ds.assertEq(postAgency, preAgency, "EXPECT-LIQUIDATE:ROLLBACK - agency should be same");

		ds.assertEq(nuggft.eps(), run.eps, "EXPECT-LIQUIDATE:ROLLBACK - eps should be the same");
		ds.assertEq(nuggft.msp(), run.msp, "EXPECT-LIQUIDATE:ROLLBACK - msp should be the same");

		stake.rollback();
		balance.rollback();

		this.clear();
	}
}
