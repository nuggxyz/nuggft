// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";

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
    // function test__print__tokenURI() public {
    //     forge.vm.startPrank(users.frank);
    //     mintHelper(500, FIX_ADDRESS, 1 ether);

    //     string memory img = nuggft.tokenURI(500);
    //     ds.emit_log_string(img);
    // }

    function setUp() public {
        reset();
    }

    function test__imageURI() public {
        uint24 token = mintable(1);

        mintHelper(token, users.frank, nuggft.msp());

        ds.emit_log_named_string("hi", nuggft.imageURI(token));
    }

    function test__image123() public {
        uint24 token = mintable(1);

        mintHelper(token, users.frank, nuggft.msp());

        bytes memory working = nuggft.image123(token, false, 1, "");

        working = nuggft.image123(token, false, 2, working);

        working = nuggft.image123(token, false, 3, working);

        ds.emit_log_named_string("hi", string(working));
    }
}

// nuggft deployed to : 0xcd7f2f0750ebe73fa37122ee6839b342ca30e58c
// xnuggft deployed to: 0x50ce039792db7f40e4ee40d0418a0efabd7badee
// dotnugg deployed to: 0x7e3cf6b416d52f9c6765ea27250ca6d724e42fce
// genesis block is: 10623680
