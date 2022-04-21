// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

contract general__NuggftV1Loan is NuggftV1Test {
    // uint24 internal constant LOAN_TOKENID = 700;
    // uint24 internal constant NUM = 4;
    // function setUp() public {
    //     reset();
    // }
    // function test__print__imageURI() public {
    //     forge.vm.startPrank(users.frank);
    //     nuggft.mint{value: 1 ether}(500);
    //     string memory img = nuggft.imageURI(500);
    //     ds.emit_log_string(img);
    // }
    // function test__print__tokenURI() public {
    //     forge.vm.startPrank(users.frank);
    //     nuggft.mint{value: 1 ether}(500);
    //     string memory img = nuggft.tokenURI(500);
    //     ds.emit_log_string(img);
    // }

    function setUp() public {
        reset();
    }

    function test__imageURI() public {
        uint24 token = mintable(1);

        expect.mint().from(users.frank).exec{value: nuggft.msp()}(token);

        ds.emit_log_named_string("hi", nuggft.imageURI(token));
    }
}
