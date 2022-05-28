// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";

contract general__premint2 is NuggftV1Test {
    function setUp() public {
        reset();
    }

    function test__premint2() public {
        (uint24 token, ) = nuggft.premintTokens();

        forge.vm.startPrank(users.frank);
        forge.vm.deal(users.frank, 5 ether);

        nuggft.premint2{value: 1 ether}(token);
    }
}
