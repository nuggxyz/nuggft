//SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "../utils/forge.sol";

import "./base.sol";
import "./stake.sol";
import "./balance.sol";

import {Expect} from "./Expect.sol";

contract expectMint is base {
    expectStake stake;
    expectBalance balance;
    Expect creator;

    constructor() {
        stake = new expectStake();
        balance = new expectBalance();
        creator = Expect(msg.sender);
    }

    struct SnapshotData {
        uint256 agency;
    }

    struct SnapshotEnv {
        uint24 tokenId;
        uint96 value;
        uint96 eps;
        uint96 msp;
    }

    struct Snapshot {
        SnapshotEnv env;
        SnapshotData data;
    }

    struct Run {
        Snapshot snapshot;
        address sender;
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    lib.txdata prepped;

    function from(address user) public returns (expectMint) {
        prepped.from = user;
        return this;
    }

    function value(uint96 val) public returns (expectMint) {
        prepped.value = val;
        return this;
    }

    function g() public returns (expectMint) {
        prepped.from = creator._globalFrom();
        return this;
    }

    function err(bytes memory b) public returns (expectMint) {
        prepped.err = b;
        return this;
    }

    function err(bytes1 b) public returns (expectMint) {
        prepped.err = abi.encodePacked(bytes4(0x7e863b48), b);
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
        nuggft.mint{value: txdata.value}(tokenId);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function start(
        uint24 tokenId,
        address sender,
        uint96 _value
    ) public {
        require(execution.length == 0, "EXPECT-MINT:START: execution already esists");

        Run memory run;

        run.sender = sender;

        SnapshotEnv memory env;
        SnapshotData memory pre;

        env.tokenId = tokenId;
        env.value = _value;
        env.msp = nuggft.msp();
        env.eps = nuggft.eps();

        pre.agency = nuggft.agency(env.tokenId);

        // ds.assertEq(pre.agency, 0, 'EXPECT-MINT:START - agency should be 0');

        balance.start(run.sender, env.value, false);
        balance.start(address(nuggft), env.value, true);

        stake.start(env.value, 1, true);

        run.snapshot.env = env;
        run.snapshot.data = pre;

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, "EXPECT-MINT:STOP: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory pre = run.snapshot.data;
        SnapshotData memory post;

        post.agency = nuggft.agency(env.tokenId);

        ds.assertGt(post.agency, 0, "EXPECT-MINT:STOP - agency should not be 0");
        if (env.eps != 0) {
            ds.assertGt(nuggft.msp(), env.msp, "EXPECT-MINT:STOP - msp should be greater than before");
            ds.assertGt(nuggft.eps(), env.eps, "EXPECT-MINT:STOP - eps should be greater than before");
        }

        // @todo - any other checks we want here?

        stake.stop();
        balance.stop();

        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, "EXPECT-MINT:ROLLBACK: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        SnapshotEnv memory env = run.snapshot.env;
        SnapshotData memory post;

        post.agency = nuggft.agency(env.tokenId);

        ds.assertEq(post.agency, 0, "EXPECT-MINT:ROLLBACK - agency should be 0");

        stake.rollback();
        balance.rollback();

        this.clear();
    }
}
