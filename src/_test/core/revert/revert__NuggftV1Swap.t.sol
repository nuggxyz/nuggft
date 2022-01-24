// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';

contract revert__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    function setUp() public {
        reset();
        forge.vm.roll(1000);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:0] - offer - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x0F__offer__successAsSelf() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = 30 * 10**16;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:1] - offer - "msg.value >= minimum offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x71__offer__successWithExactMinOffer() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = 10**8;
        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(value, 1, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__revert__NuggftV1Swap__0x71__offer__successWithHigherMinOffer() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = 10**8 + 1;

        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(value, 1, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__revert__NuggftV1Swap__0x71__offer__passWithOneWeiLessThanMin() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = 10**8 - 1;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            // forge.vm.expectRevert(hex'21');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x71__offer__failWithOneWeiLessThanMinAfterSomeValue() public {
        uint160 tokenId = nuggft.epoch();

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, 1 ether);
            nuggft.mint{value: 1 ether}(500);

            uint96 value = 10**8 - 1;

            forge.vm.deal(users.frank, value);
            forge.vm.expectRevert(hex'71');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x71__offer__passWithZero() public {
        uint160 tokenId = nuggft.epoch();

        uint96 value = 0;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            // forge.vm.expectRevert(hex'21');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x71__offer__failWithZeroAfterSomeValue() public {
        uint160 tokenId = nuggft.epoch();

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, 1 ether);
            nuggft.mint{value: 1 ether}(500);

            uint96 value = 0;

            forge.vm.deal(users.frank, value);
            forge.vm.expectRevert(hex'71');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3a] - offer - "if commiting, offerer should not be owner of sell"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x0F__successWithNotOwner() public {
        (uint160 tokenId, uint96 floor) = scenario_dee_has_sold_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(1 ether, 0, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__revert__NuggftV1Swap__0x0F__successWithOwnerAfterSomeoneElseOffers() public {
        (uint160 tokenId, uint96 floor) = scenario_dee_has_sold_a_token();

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
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        forge.vm.startPrank(users.dee);
        {
            nuggft.offer{value: value2}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    function test__revert__NuggftV1Swap__0x0F__failWithOwnerOnCommit() public {
        (uint160 tokenId, uint96 floor) = scenario_dee_has_sold_a_token();

        uint96 value = floor + 1 ether * 2;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert(hex'0F');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3b] - offer - "if not minting, offerer must claim previous offers for the specific token"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__0x0F__successWithUserWithNoPrevClaim() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.frank, value);

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(1 ether, 0, dir.up);

        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    // LOL - MASSIVE bug found with this test
    function test__revert__NuggftV1Swap__0x0F__successWithPrevClaimUserAfterClaiming() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(users.dee));
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x0F__failWtihUserWithPrevClaim() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert(hex'0F');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:4] - offer - "if not minting, sell data must exist"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__0x24__failWithNoSwap() public {
        uint160 tokenId = scenario_mac_has_claimed_a_token_dee_sold();

        uint96 value = 1 ether;

        forge.vm.deal(users.frank, value);

        forge.vm.startPrank(users.frank);
        {
            forge.vm.expectRevert(hex'24');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x24__failWithNonexistantToken() public {
        uint160 tokenId = 50000;

        uint96 value = 1 ether;

        forge.vm.deal(users.frank, value);

        forge.vm.startPrank(users.frank);
        {
            forge.vm.expectRevert(hex'24');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x24__successWithSwap() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        nuggft.epoch();

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(users.dee));

            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:5] - offer - "if commiting, msg.value must be >= total eth per share"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x25__passWithVeryHighEPS() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint160 tokenId2 = 1500;

        uint96 value = 1500 ether;
        uint96 value2 = floor + 1 ether;

        forge.vm.deal(users.frank, value + value2);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(tokenId2);

            // forge.vm.expectRevert(hex'25');
            nuggft.offer{value: value2}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x25__successWithLowEPS() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint160 tokenId2 = 1500;

        uint96 value = floor + .5 ether;
        uint96 value2 = floor + 1 ether;

        nuggft.eps();
        nuggft.msp();

        forge.vm.deal(users.frank, value + value2);

        forge.vm.startPrank(users.frank);
        {
            nuggft.mint{value: value}(tokenId2);

            nuggft.offer{value: value2}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:6] - offerItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__0x26__successAsOwnerOfBuyerTokenId() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.charlie, value);

        forge.vm.startPrank(users.charlie);
        {
            nuggft.offerItem{value: value}(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    // function test__revert__NuggftV1Swap__0x26__failAsOperator() public {
    //     (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

    //     uint160 charliesTokenId = scenario_charlie_has_a_token();

    //     uint96 value = floor + 1 ether;

    //     forge.vm.deal(users.mac, value);

    //     forge.vm.startPrank(users.charlie);
    //     {
    //         nuggft.setApprovalForAll(users.mac, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.mac);
    //     {
    //         forge.vm.expectRevert(hex'26');
    //         nuggft.offerItem{value: value}(charliesTokenId, tokenId, itemId);
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Swap__0x26__failAsNotOperator() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.mac, value);

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert(hex'26');
            nuggft.offerItem{value: value}(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:7] - offerItem - "offerer should not be owner of sell"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x27__successWithNotOwner() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.charlie, value);

        forge.vm.startPrank(users.charlie);
        {
            nuggft.offerItem{value: value}(charliesTokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x27__successWithSameUserDifferentToken() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint160 tokenId2 = scenario_dee_has_a_token_2();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            nuggft.offerItem{value: value}(tokenId2, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x27__failWithUserAndOwningToken() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert(hex'0f');
            nuggft.offerItem{value: value}(tokenId, tokenId, itemId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:8] - claim - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__0x28__successAsSelf() public {
        uint160 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.mac);
        {
            nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(users.mac));
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:9] - claimItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x29__successAsOwnerOfBuyerTokenId() public {
        (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_sold_an_item_and_charlie_can_claim();

        forge.vm.startPrank(users.charlie);
        {
            nuggft.claimItem(lib.sarr160(charliesTokenId), lib.sarr160(tokenId), lib.sarr16(itemId));
        }
        forge.vm.stopPrank();
    }

    // function test__revert__NuggftV1Swap__0x29__failAsOperator() public {
    //     (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_sold_an_item_and_charlie_can_claim();

    //     forge.vm.startPrank(users.charlie);
    //     {
    //         nuggft.setApprovalForAll(users.mac, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.mac);
    //     {
    //         forge.vm.expectRevert(hex'29');
    //         nuggft.claimItem(charliesTokenId, tokenId, itemId);
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Swap__0x29__failAsNotOperator() public {
        (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_sold_an_item_and_charlie_can_claim();

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert(hex'29');
            nuggft.claimItem(lib.sarr160(charliesTokenId), lib.sarr160(tokenId), lib.sarr16(itemId));
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:A] - sell - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x2A__successAsSelf() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

        uint96 value = 2 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.sell(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    // function test__revert__NuggftV1Swap__0x2A__failsAsOperator() public {
    //     uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

    //     uint96 value = 2 ether;

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.setApprovalForAll(users.dennis, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.expectRevert(hex'2A');
    //         nuggft.sell(tokenId, value);
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Swap__0x2A__failAsNotOperator() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

        uint96 value = 2 ether;

        forge.vm.startPrank(users.dennis);
        {
            forge.vm.expectRevert(hex'2A');
            nuggft.sell(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:B] - sell - "floor >= eps"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x2B__successWithEqualEPS() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor;

        forge.vm.startPrank(users.dee);
        {
            nuggft.sell(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2B__successWithOneWeiTooHigh() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor + 1;

        forge.vm.startPrank(users.dee);
        {
            nuggft.sell(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2B__revertWithOneWeiTooLow() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor - 1;

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert(hex'2B');
            nuggft.sell(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2B__revertWithZero() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 value = 0;

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert(hex'2B');
            nuggft.sell(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2B__revertWithHalfFloor() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor / 2;

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert(hex'2B');
            nuggft.sell(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2B__successWithWayTooHigh() public {
        uint160 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor + 30 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.sell(tokenId, value);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:C] - sellItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x2C__successAsOwnerOfBuyerTokenId() public {
        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        uint96 value = 1 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.sellItem(tokenId, itemId, value);
        }
        forge.vm.stopPrank();
    }

    // function test__revert__NuggftV1Swap__0x2C__failAsOperator() public {
    //     (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

    //     uint96 value = 1 ether;

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.setApprovalForAll(users.dennis, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.expectRevert(hex'2C');
    //         nuggft.sellItem(tokenId, itemId, value);
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Swap__0x2C__failAsNotOperator() public {
        (uint160 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        uint96 value = 1 ether;

        forge.vm.startPrank(users.dennis);
        {
            forge.vm.expectRevert(hex'2C');
            nuggft.sellItem(tokenId, itemId, value);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:D] - sellItem - "cannot sell two of same item at same time" @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:E] - checkClaimerIsWinnerOrLoser - "invalid offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x2E__successPrevSwapperCanClaimAfterNewSwapHasStarted() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(users.dee));
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2E__failNoOffer() public {
        uint160 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.charlie);
        {
            forge.vm.expectRevert(hex'2E');
            nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(users.charlie));
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2E__successAsLeader() public {
        uint160 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.mac);
        {
            nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(users.mac));
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2E__successAsOwner() public {
        uint160 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(users.dee));
        }
        forge.vm.stopPrank();
    }

    // function test__revert__NuggftV1Swap__0x2E__failAsOperator() public {
    //     uint160 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

    //     forge.vm.startPrank(users.mac);
    //     {
    //         nuggft.setApprovalForAll(users.dennis, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.expectRevert(hex'2E');
    //         nuggft.claim(lib.sarr160(tokenId));
    //     }
    //     forge.vm.stopPrank();
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:F] - offer - "sell must be total"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x2F__successOfferInActiveSwap() public {
        (uint160 tokenId, uint96 eth) = scenario_dee_has_sold_a_token_and_mac_has_offered();

        uint96 value = eth + 1 ether;

        forge.vm.startPrank(users.charlie);
        {
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2F__failOfferInOldSwap() public {
        (uint160 tokenId, uint96 eth) = scenario_dee_has_sold_a_token_and_mac_has_offered();

        forge.vm.roll(2000);

        uint96 value = eth + 1 ether;

        forge.vm.startPrank(users.charlie);
        {
            forge.vm.expectRevert(hex'2F');

            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x2F__failOfferInFutureSwap() public {
        uint160 tokenId = 50000;

        uint96 value = 1 ether;

        forge.vm.startPrank(users.charlie);
        {
            forge.vm.expectRevert(hex'24');
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }
}

// @todo - make sure eth ends up where we want it
