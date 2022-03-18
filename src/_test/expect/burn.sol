//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../utils/forge.sol";

import "./base.sol";
import "./stake.sol";
import "./balance.sol";
import {Expect} from "./Expect.sol";

contract expectBurn is base {
    expectStake stake;
    expectBalance balance;
    Expect creator;

    constructor() {
        stake = new expectStake();
        balance = new expectBalance();
        creator = Expect(msg.sender);
    }

    lib.txdata prepped;

    function from(address user) public returns (expectBurn) {
        prepped.from = user;
        return this;
    }

    function value(uint96 val) public returns (expectBurn) {
        prepped.value = val;
        return this;
    }

    function err(bytes memory b) public returns (expectBurn) {
        prepped.err = b;
        return this;
    }

    function err(bytes1 b) public returns (expectBurn) {
        prepped.err = abi.encodePacked(bytes4(0x7e863b48), b);
        return this;
    }

    function g() public returns (expectBurn) {
        prepped.from = creator._globalFrom();
        return this;
    }

    function exec(uint160 tokenId) public payable {
        lib.txdata memory _prepped = prepped;
        _prepped.value += uint96(msg.value);

        delete prepped;
        exec(tokenId, _prepped);
    }

    struct Run {
        address sender;
        uint160 tokenId;
        uint96 eps;
        uint256 agency;
    }

    bytes execution;

    function clear() public {
        delete execution;
    }

    function exec(uint160 tokenId, lib.txdata memory txdata) public {
        this.start(tokenId, txdata.from);
        forge.vm.startPrank(txdata.from);
        if (txdata.err.length > 0) forge.vm.expectRevert(txdata.err);
        nuggft.burn(tokenId);
        forge.vm.stopPrank();
        txdata.err.length > 0 ? this.rollback() : this.stop();
    }

    function start(uint160 tokenId, address sender) public {
        require(execution.length == 0, "EXPECT-BURN:START: execution already exists");

        Run memory run;

        run.sender = sender;

        run.eps = nuggft.eps();

        run.agency = nuggft.agency(tokenId);

        balance.start(run.sender, run.eps, true);
        balance.start(address(nuggft), run.eps, false);

        stake.start(run.eps, 1, false);

        execution = abi.encode(run);
    }

    function stop() public {
        require(execution.length > 0, "EXPECT-BURN:STOP: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        uint96 postEps = nuggft.eps();

        uint256 postAgency = nuggft.agency(run.tokenId);

        ds.assertEq(postAgency, 0, "EXPECT-BURN:STOP: aagency should be zero");

        ds.assertEq(postEps, run.eps, "EXPECT-BURN:STOP: eps should not have changed");

        balance.stop();
        stake.stop();
        this.clear();
    }

    function rollback() public {
        require(execution.length > 0, "EXPECT-BURN:ROLLBACK: execution does not exist");

        Run memory run = abi.decode(execution, (Run));

        uint96 postEps = nuggft.eps();

        uint256 postAgency = nuggft.agency(run.tokenId);

        ds.assertEq(postAgency, run.agency, "EXPECT-BURN:ROLLBACK: agency should be the same");

        ds.assertEq(postEps, run.eps, "EXPECT-BURN:ROLLBACK: eps should be the same");

        stake.rollback();
        balance.rollback();

        this.clear();
    }
}
