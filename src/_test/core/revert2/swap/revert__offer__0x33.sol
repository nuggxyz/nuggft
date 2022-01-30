// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../../NuggftV1.test.sol';

contract revert__offer__0x33 is NuggftV1Test {
    using SafeCast for uint96;

    function setUp() public {
        reset();

        forge.vm.roll(1000);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:0] - offer - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // function test__revert__offer__0x33__0x0F__offer__successAsSelf() public {
    //     uint160 tokenId = nuggft.epoch();

    //     uint96 value = 30 * 10**16;

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.deal(users.frank, value);
    //         nuggft.offer{value: value}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }
}
