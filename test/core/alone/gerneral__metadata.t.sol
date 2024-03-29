// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

contract general__NuggftV1Loan is NuggftV1Test {
	// uint24 internal constant LOAN_TOKENID = 700;
	// uint24 internal constant NUM = 4;
	// function setUp() public {
	//     reset();
	// }
	// function test__print__imageURI() public {
	//     forge.vm.startPrank(users.frank);
	//     mintHelper(500, FIX_ADDRESS, 1 ether);

	//     string memory img = nuggft.imageURI(500);
	//     ds.emit_log_string(img);
	// }

	function setUp() public {
		reset();
	}

	function test__imageURI() public {
		uint24 token = mintable(2);

		mintHelper(token, users.frank, nuggft.msp());

		ds.emit_log_named_string("hi", nuggft.imageURI(token));
	}

	function test__tokenURI() public {
		uint24 token = mintable(1);

		mintHelper(token, users.frank, nuggft.msp());

		ds.emit_log_named_string("hi", nuggft.tokenURI(token));
	}

	function test__image123() public {
		uint24 token = mintable(1);

		mintHelper(token, users.frank, nuggft.msp());

		bytes memory working = nuggft.image123(token, false, 1, "");

		working = nuggft.image123(token, false, 2, working);

		working = nuggft.image123(token, false, 3, working);

		ds.emit_log_named_string("hi", string(working));
	}

	function test__sloop() public {
		uint24 token = mintable(1);

		mintHelper(token, users.frank, nuggft.msp());

		bytes memory check = xnuggft.sloop();
		uint256 len = check.length / 37;

		for (uint256 i = 0; i < len; i++) {
			ds.emit_log_named_bytes(DotnuggV1Lib.toString(i), byteslib.slice(check, i * 37, 37));
		}
	}

	function test__tloop() public {
		bytes memory check = xnuggft.tloop();

		uint256 len = check.length / 3;

		for (uint256 i = 0; i < len; i++) {
			ds.emit_log_named_uint(DotnuggV1Lib.toString(i), uint24(bytes3(byteslib.slice(check, i * 3, 3))));
		}
	}

	function test__iloop() public {
		bytes memory check = xnuggft.iloop();

		uint256 len = check.length / 2;

		for (uint256 i = 0; i < len; i++) {
			ds.emit_log_named_uint(DotnuggV1Lib.toString(i), uint16(bytes2(byteslib.slice(check, i * 2, 2))));
		}
	}

	function test__metadata() public {
		nuggft.name();
		nuggft.symbol();
		// nuggft.symbol2();
		// nuggft.symbol3();

		// uint24[] memory tokens = nuggft.tokensOf(address(nuggft));
		// uint256 len = DotnuggV1Lib.lengthOf(dotnugg, 1);
		// for (uint24 i = 0; i < len; i++) {
		//     uint256 bal = xnuggft.balanceOf(address(nuggft), 1000 + i);
		//     ds.emit_log_named_uint(DotnuggV1Lib.toString(i), bal);
		// }

		// address(nuggft).code.length;

		// nuggft.tokenURI(nuggft.epoch());
	}
}

// nuggft deployed to : 0xcd7f2f0750ebe73fa37122ee6839b342ca30e58c
// xnuggft deployed to: 0x50ce039792db7f40e4ee40d0418a0efabd7badee
// dotnugg deployed to: 0x7e3cf6b416d52f9c6765ea27250ca6d724e42fce
// genesis block is: 10623680
