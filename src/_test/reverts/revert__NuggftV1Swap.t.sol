// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';

contract revert__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    function setUp() public {
        reset();
        forge.vm.roll(15000);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:0] - delegate - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_0__successAsSelf() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = 30 * 10**16;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:1] - delegate - "msg.value >= minimum offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_1__successWithExactMinOffer() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = nuggft.MIN_OFFER();
        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(value, 1, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__revert__NuggftV1Swap__S_1__successWithHigherMinOffer() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = nuggft.MIN_OFFER() + 1;

        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(value, 1, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__revert__NuggftV1Swap__S_1__failWithOneWeiLessThanMin() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = nuggft.MIN_OFFER() - 1;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            forge.vm.expectRevert('S:1');
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_1__failWithZero() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = 0;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            forge.vm.expectRevert('S:1');
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3a] - delegate - "if commiting, offerer should not be owner of swap"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_R__successWithNotOwner() public {
        (uint160 tokenId, uint96 floor) = scenario_dee_has_swapped_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(1 ether, 0, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__revert__NuggftV1Swap__S_R__successWithOwnerAfterSomeoneElseDelegates() public {
        (uint160 tokenId, uint96 floor) = scenario_dee_has_swapped_a_token();

        uint96 value = floor + 1 ether;

        uint96 value2 = floor + 2 ether;

        forge.vm.deal(users.frank, value);
        forge.vm.deal(users.dee, value2);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(users.dee, value2, dir.down);
        expectBalChange(_nuggft, value + value2, dir.up);
        expectStakeChange(3 ether, 0, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dee);
        {
            nuggft.delegate{value: value2}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__revert__NuggftV1Swap__S_R__failWithOwnerOnCommit() public {
        (uint160 tokenId, uint96 floor) = scenario_dee_has_swapped_a_token();

        uint96 value = floor + 1 ether * 2;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert('S:R');
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3b] - delegate - "if not minting, offerer must claim previous offers for the specific token"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__S_R__successWithUserWithNoPrevClaim() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(1 ether, 0, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    // LOL - MASSIVE bug found with this test
    function test__revert__NuggftV1Swap__S_R__successWithPrevClaimUserAfterClaiming() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(tokenId);
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_R__failWtihUserWithPrevClaim() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert('S:R');
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:4] - delegate - "if not minting, swap data must exist"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__S_4__failWithNoSwap() public {
        uint160 tokenId = scenario_mac_has_claimed_a_token_dee_swapped();

        uint96 value = 1 ether;

        forge.vm.deal(users.frank, value);

        forge.vm.startPrank(users.frank);
        {
            forge.vm.expectRevert('S:4');
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_4__failWithNonexistantToken() public {
        uint160 tokenId = 50000;

        uint96 value = 1 ether;

        forge.vm.deal(users.frank, value);

        forge.vm.startPrank(users.frank);
        {
            forge.vm.expectRevert('S:4');
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_4__successWithSwap() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(tokenId);

            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:5] - delegate - "if commiting, msg.value must be >= total eth per share"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_5__failWithVeryHighEPS() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        uint160 tokenId2 = 1500;

        uint96 value = 1500 ether;
        uint96 value2 = floor + 1 ether;

        forge.vm.deal(users.frank, value + value2);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(tokenId2);

            forge.vm.expectRevert('S:5');
            nuggft.delegate{value: value2}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_5__successWithLowEPS() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        uint160 tokenId2 = 1500;

        uint96 value = floor + .5 ether;
        uint96 value2 = floor + 1 ether;

        nuggft.eps();
        nuggft.msp();

        forge.vm.deal(users.frank, value + value2);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(tokenId2);

            nuggft.delegate{value: value2}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:6] - delegateItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__S_6__successAsOwnerOfBuyerTokenId() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.charlie, value);

        forge.vm.startPrank(users.charlie);
        {
            nuggft.delegateItem{value: value}(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_6__failAsOperator() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.mac, value);

        forge.vm.startPrank(users.charlie);
        {
            nuggft.setApprovalForAll(users.mac, true);
        }
        forge.vm.stopPrank();

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert('S:6');
            nuggft.delegateItem{value: value}(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_6__failAsNotOperator() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.mac, value);

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert('S:6');
            nuggft.delegateItem{value: value}(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:7] - delegateItem - "offerer should not be owner of swap"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_7__successWithNotOwner() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.charlie, value);

        forge.vm.startPrank(users.charlie);
        {
            nuggft.delegateItem{value: value}(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_7__successWithSameUserDifferentToken() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 tokenId2 = scenario_dee_has_a_token_2();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            nuggft.delegateItem{value: value}(tokenId2, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_7__failWithUserAndOwningToken() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert('S:7');
            nuggft.delegateItem{value: value}(tokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:8] - claim - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__S_8__successAsSelf() public {
        uint160 tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.mac);
        {
            nuggft.claim(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:9] - claimItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_9__successAsOwnerOfBuyerTokenId() public {
        (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        forge.vm.startPrank(users.charlie);
        {
            nuggft.claimItem(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_9__failAsOperator() public {
        (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        forge.vm.startPrank(users.charlie);
        {
            nuggft.setApprovalForAll(users.mac, true);
        }
        forge.vm.stopPrank();

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert('S:9');
            nuggft.claimItem(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_9__failAsNotOperator() public {
        (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert('S:9');
            nuggft.claimItem(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:A] - swap - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_A__successAsSelf() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        uint96 value = 2 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_A__failsAsOperator() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        uint96 value = 2 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.setApprovalForAll(users.dennis, true);
        }
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dennis);
        {
            forge.vm.expectRevert('S:A');
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_A__failAsNotOperator() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        uint96 value = 2 ether;

        forge.vm.startPrank(users.dennis);
        {
            forge.vm.expectRevert('S:A');
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:B] - swap - "floor >= eps"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_B__successWithEqualEPS() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor;

        forge.vm.startPrank(users.dee);
        {
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_B__successWithOneWeiTooHigh() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor + 1;

        forge.vm.startPrank(users.dee);
        {
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_B__revertWithOneWeiTooLow() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor - 1;

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert('S:B');
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_B__revertWithZero() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 value = 0;

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert('S:B');
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_B__revertWithHalfFloor() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor / 2;

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert('S:B');
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_B__successWithWayTooHigh() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor + 30 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.swap(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:C] - swapItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_C__successAsOwnerOfBuyerTokenId() public {
        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        uint96 value = 1 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.swapItem(tokenId, itemId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_C__failAsOperator() public {
        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        uint96 value = 1 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.setApprovalForAll(users.dennis, true);
        }
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dennis);
        {
            forge.vm.expectRevert('S:C');
            nuggft.swapItem(tokenId, itemId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_C__failAsNotOperator() public {
        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        uint96 value = 1 ether;

        forge.vm.startPrank(users.dennis);
        {
            forge.vm.expectRevert('S:C');
            nuggft.swapItem(tokenId, itemId, value);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:D] - swapItem - "cannot sell two of same item at same time" @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:E] - checkClaimerIsWinnerOrLoser - "invalid offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_E__successPrevSwapperCanClaimAfterNewSwapHasStarted() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_E__failNoOffer() public {
        uint160 tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.charlie);
        {
            forge.vm.expectRevert('S:E');
            nuggft.claim(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_E__successAsLeader() public {
        uint160 tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.mac);
        {
            nuggft.claim(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_E__successAsOwner() public {
        uint160 tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_E__failAsOperator() public {
        uint160 tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.mac);
        {
            nuggft.setApprovalForAll(users.dennis, true);
        }
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dennis);
        {
            forge.vm.expectRevert('S:E');
            nuggft.claim(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:F] - offer - "swap must be total"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_F__successOfferInActiveSwap() public {
        (uint160 tokenId, uint96 eth) = scenario_dee_has_swapped_a_token_and_mac_has_delegated();

        uint96 value = eth + 1 ether;

        forge.vm.startPrank(users.charlie);
        {
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_F__failOfferInOldSwap() public {
        (uint160 tokenId, uint96 eth) = scenario_dee_has_swapped_a_token_and_mac_has_delegated();

        forge.vm.roll(2000);

        uint96 value = eth + 1 ether;

        forge.vm.startPrank(users.charlie);
        {
            forge.vm.expectRevert('S:F');

            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__S_F__failOfferInFutureSwap() public {
        uint160 tokenId = 50000;

        uint96 value = 1 ether;

        forge.vm.startPrank(users.charlie);
        {
            forge.vm.expectRevert('S:4');
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }
}

// @todo - make sure eth ends up where we want it
