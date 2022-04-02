// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

contract txgas__NuggftV1Proof is NuggftV1Test {
    function setUp() public {
        reset();

        forge.vm.prank(users.safe);
        // nuggft.trustedMint2(users.frank);
    }

    function test__txgas__NuggftV1Proof__mint2() public {
        forge.vm.prank(users.frank);
        // nuggft.mint2(users.dee);
    }
}
