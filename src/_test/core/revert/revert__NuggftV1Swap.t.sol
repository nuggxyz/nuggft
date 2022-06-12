// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";

abstract contract revert__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    modifier revert__NuggftV1Swap__setUp() {
        TOKEN1 = mintable(1);
        _;
    }
    uint24 private TOKEN1;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:0] - offer - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x99__offer__successAsSelf() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch();

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

    function test__revert__NuggftV1Swap__0x71__offer__passWithExactMinOffer() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch();

        // uint96 value = 10 gwei;
        // forge.vm.deal(users.frank, value);

        expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, tokenId)}(tokenId);

        // expect.balance().start(users.frank, value, false);
        // expect.balance().start(_nuggft, value, true);
        // expect.stake().start(value, 1, true);
        // forge.vm.startPrank(users.frank);
        // {
        //     // forge.vm.expectRevert(hex"7e863b48_68");
        //     nuggft.offer{value: value}(tokenId);
        // }
        // forge.vm.stopPrank();

        // expect.stake().stop();
        // expect.balance().stop();
    }

    function test__revert__NuggftV1Swap__0x71__offer__successWithHigherMinOffer() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch();

        expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, tokenId) + 1}(tokenId);
    }

    // function test__revert__NuggftV1Swap__0x68__offer__failWithOneWeiLessThanMin() public revert__NuggftV1Swap__setUp {
    //     uint24 tokenId = nuggft.epoch();

    //     uint96 value = 10 gwei - .1 gwei;

    //     expect.offer().from(users.frank).exec{value: nuggft.vfo(users.frank, tokenId)}(tokenId);

    // }

    function test__revert__NuggftV1Swap__0x71__offer__mint__failWithOneWeiLessThanMinAfterSomeValue() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch();
        // subtract 1 for when the "round up" is nothing

        uint96 abc = ((nuggft.vfo(users.frank, tokenId) - 1) / LOSS) * LOSS;

        ds.emit_log_named_uint("abc", abc);

        expect.offer().from(users.frank).err(0x71).exec{value: abc}(tokenId);
    }

    function test__revert__NuggftV1Swap__0x71__offer__mint__failWithOneWeiLessThanMinAfterSomeValueMsp() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch();
        (uint96 _trueMsp, , , , ) = nuggft.external__minSharePriceBreakdown();

        expect.offer().from(users.frank).err(0x71).exec{value: _trueMsp - 1}(tokenId);
    }

    function test__revert__NuggftV1Swap__0x71__offer__mint__failWithOneWeiMoreThanMinAfterSomeValueMsp() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch();
        (uint96 _trueMsp, , , , ) = nuggft.external__minSharePriceBreakdown();

        expect.offer().from(users.frank).err(0x71).exec{value: _trueMsp + 1}(tokenId);
    }

    function test__revert__NuggftV1Swap__0x71__offer__mint__failMspAfterSomeValue() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch();

        (uint96 _trueMsp, , , , ) = nuggft.external__minSharePriceBreakdown();

        expect.offer().from(users.frank).err(0x71).exec{value: _trueMsp}(tokenId);
    }

    function test__revert__NuggftV1Swap__0x68__offer__mint__failWithZero() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch();

        uint96 value = 0;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            forge.vm.expectRevert(hex"7e863b48_71");
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x71__offer__mint__failWithZeroAfterSomeValue() public revert__NuggftV1Swap__setUp {
        mintHelper(TOKEN1, users.frank, 1 ether);
        uint24 tokenId = nuggft.epoch();

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, 1 ether);

            uint96 value = 0;

            forge.vm.deal(users.frank, value);
            forge.vm.expectRevert(hex"7e863b48_71");
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3a] - offer - "if commiting, offerer should not be owner of sell"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x99__successWithNotOwner() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_dee_has_sold_a_token();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.frank, value);

        expect.balance().start(users.frank, value, false);
        expect.balance().start(_nuggft, value, true);
        expect.stake().start(1 ether, 0, true);
        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
        expect.stake().stop();

        expect.balance().stop();
    }

    function test__revert__NuggftV1Swap__0x99__successWithOwnerAfterSomeoneElseOffers() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_dee_has_sold_a_token();

        uint96 value = floor + 1 ether;

        uint96 value2 = floor + 2 ether;

        forge.vm.deal(users.frank, value);
        forge.vm.deal(users.dee, value2);

        expect.balance().start(users.frank, value, false);
        expect.balance().start(users.dee, value2, false);
        expect.balance().start(_nuggft, value + value2, true);
        expect.stake().start(3 ether, 0, true);
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
        expect.stake().stop();

        expect.balance().stop();
    }

    function test__revert__NuggftV1Swap__0x99__failWithOwnerOnCommit() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_dee_has_sold_a_token();

        uint96 value = floor + 1 ether * 2;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            forge.vm.expectRevert(hex"7e863b48_99");
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3b] - offer - "if not minting, offerer must claim previous offers for the specific token"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__0x99__successWithUserWithNoPrevClaim() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.frank, value);

        expect.balance().start(users.frank, value, false);
        expect.balance().start(_nuggft, value, true);
        expect.stake().start(1 ether, 0, true);
        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value}(tokenId);
        }
        forge.vm.stopPrank();
        expect.stake().stop();

        expect.balance().stop();
    }

    // LOL - MASSIVE bug found with this test
    function test__revert__NuggftV1Swap__0x99__successWithPrevClaimUserAfterClaiming() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        expect.claim().from(users.dee).exec(array.b24(tokenId), lib.sarrAddress(users.dee));

        expect.offer().from(users.dee).exec{value: nuggft.vfo(users.dee, tokenId)}(tokenId);
    }

    function test__revert__NuggftV1Swap__0x99__failWtihUserWithPrevClaim() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint96 value = floor + 1 ether;

        expect.offer().from(users.dee).err(0x99).exec{value: value}(tokenId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:4] - offer - "if not minting, sell data must exist"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__0xA0__failWithNoSwap() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_mac_has_claimed_a_token_dee_sold();

        uint96 value = 1 ether;

        expect.offer().from(users.frank).err(0xA0).exec{value: value}(tokenId);
    }

    function test__revert__NuggftV1Swap__0xA0__failWithNonexistantToken() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = earlyMintable(0) - 1;

        uint96 value = 1 ether;

        require(nuggft.agency(tokenId) == 0, "NON EXISTANT REQUIRED");

        expect.offer().from(users.frank).err(0x65).exec{value: value}(tokenId);
    }

    function test__revert__NuggftV1Swap__0xA0__passWithPreMint() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = trustMintable(0) - 1;

        uint96 value = 1 ether;

        require(nuggft.agency(tokenId) == 0, "NON EXISTANT REQUIRED");

        // TODO update offer expect for premints
        // expect.offer().from(users.frank).exec{value: value}(tokenId);
    }

    function test__revert__NuggftV1Swap__0xA0__successWithSwap() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        nuggft.epoch();

        expect.claim().from(users.dee).exec(array.b24(tokenId), lib.sarrAddress(users.dee));

        expect.offer().from(users.dee).exec{value: nuggft.vfo(users.dee, tokenId)}(tokenId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:5] - offer - "if commiting, msg.value must be >= total eth per share"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x25__passWithVeryHighEPS() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint24 tokenId2 = mintable(1000);

        uint96 value = 1500 ether;
        uint96 value2 = floor + 1 ether;

        forge.vm.deal(users.frank, value + value2);
        mintHelper(tokenId2, users.frank, value);

        forge.vm.startPrank(users.frank);
        {
            // forge.vm.expectRevert(hex'7e863b48_25');
            nuggft.offer{value: value2}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Swap__0x25__successWithLowEPS() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        uint24 tokenId2 = mintable(1000);

        uint96 value = floor + .5 ether;
        uint96 value2 = floor + 1 ether;

        nuggft.eps();
        nuggft.msp();

        forge.vm.deal(users.frank, value + value2);
        mintHelper(tokenId2, users.frank, value);

        forge.vm.startPrank(users.frank);
        {
            nuggft.offer{value: value2}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:6] - offer - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__0x26__successAsOwnerOfBuyerTokenId() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint24 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        expect.offer().from(users.charlie).exec{value: value}(charliesTokenId, tokenId, itemId);
    }

    // function test__revert__NuggftV1Swap__0x26__failAsOperator() public revert__NuggftV1Swap__setUp {
    //     (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

    //     uint24 charliesTokenId = scenario_charlie_has_a_token();

    //     uint96 value = floor + 1 ether;

    //     forge.vm.deal(users.mac, value);

    //     forge.vm.startPrank(users.charlie);
    //     {
    //         nuggft.setApprovalForAll(users.mac, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.mac);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_26');
    //          nuggft.offer{value: value}(uint24((charliesTokenId << 40) | (uint256(itemId) << 24) | tokenId));
    // }
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Swap__0xA2__failAsNotOperator() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint24 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        expect.offer().err(0xA2).from(users.mac).exec{value: value}(charliesTokenId, tokenId, itemId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:7] - offer - "offerer should not be owner of sell"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x99__item__successWithNotOwner() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint24 charliesTokenId = scenario_charlie_has_a_token();

        uint96 value = floor + 1 ether;

        expect.offer().from(users.charlie).exec{value: value}(charliesTokenId, tokenId, itemId);
    }

    function test__revert__NuggftV1Swap__0x99__successWithSameUserDifferentToken() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint24 tokenId2 = scenario_dee_has_a_token_2();

        uint96 value = floor + 1 ether;

        expect.offer().from(users.dee).exec{value: value}(tokenId2, tokenId, itemId);
    }

    function test__revert__NuggftV1Swap__0x99__failWithUserAndOwningToken() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        expect.offer().err(0x99).from(users.dee).exec{value: value}(tokenId, tokenId, itemId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:8] - claim - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__0x28__successAsSelf() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

        expect.claim().from(users.mac).exec(tokenId, users.mac);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:9] - claimItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x29__successAsOwnerOfBuyerTokenId() public revert__NuggftV1Swap__setUp {
        (uint24 charliesTokenId, uint24 tokenId, uint16 itemId) = scenario_dee_has_sold_an_item_and_charlie_can_claim();

        expect.claim().from(users.charlie).exec(tokenId, charliesTokenId, itemId);
    }

    // function test__revert__NuggftV1Swap__0x29__failAsOperator() public revert__NuggftV1Swap__setUp {
    //     (uint24 charliesTokenId, uint24 tokenId, uint16 itemId) = scenario_dee_has_sold_an_item_and_charlie_can_claim();

    //     forge.vm.startPrank(users.charlie);
    //     {
    //         nuggft.setApprovalForAll(users.mac, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.mac);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_29');
    //         nuggft.claimItem(charliesTokenId, tokenId, itemId);
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Swap__0x29__failAsNotOperator() public revert__NuggftV1Swap__setUp {
        (uint24 charliesTokenId, uint24 tokenId, uint16 itemId) = scenario_dee_has_sold_an_item_and_charlie_can_claim();

        nuggft.floop(charliesTokenId);

        expect.claim().from(users.mac).exec(tokenId, charliesTokenId, itemId);

        nuggft.floop(charliesTokenId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:A] - sell - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0xA1__successAsSelf() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_a_token_and_can_sell();

        uint96 value = 2 ether;

        expect.sell().from(users.dee).exec(tokenId, value);
    }

    // function test__revert__NuggftV1Swap__0xA1__failsAsOperator() public revert__NuggftV1Swap__setUp {
    //     uint24 tokenId = scenario_dee_has_a_token_and_can_sell();

    //     uint96 value = 2 ether;

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.setApprovalForAll(users.dennis, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_2A');
    //         nuggft.sell(tokenId, value);
    //     }
    //     forge.vm.stopPrank();
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:B] - sell - "floor >= eps"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x70__successWithEqualEPS() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor;

        expect.sell().from(users.dee).exec(tokenId, value);
    }

    function test__revert__NuggftV1Swap__0x70__successWithOneWeiTooHigh() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor + 1;

        expect.sell().from(users.dee).exec(tokenId, value);
    }

    function test__revert__NuggftV1Swap__0x70__revertWithOneWeiTooLow() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor - 1;

        expect.sell().err(0x70).from(users.dee).exec(tokenId, value);
    }

    function test__revert__NuggftV1Swap__0x70__revertWithZero() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 value = 0;

        expect.sell().err(0x70).from(users.dee).exec(tokenId, value);
    }

    function test__revert__NuggftV1Swap__0x70__revertWithHalfFloor() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor / 2;

        expect.sell().err(0x70).from(users.dee).exec(tokenId, value);
    }

    function test__revert__NuggftV1Swap__0x70__successWithWayTooHigh() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_a_token_and_can_sell();

        scenario_frank_has_a_token_and_spent_50_eth();

        uint96 floor = nuggft.eps();

        uint96 value = floor + 30 ether;

        expect.sell().from(users.dee).exec(tokenId, value);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:C] - sell - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0x2C__successAsOwnerOfBuyerTokenId() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        uint96 value = 1 ether;

        forge.vm.startPrank(users.dee);
        {
            nuggft.sell(tokenId, itemId, value);
        }
        forge.vm.stopPrank();
    }

    // function test__revert__NuggftV1Swap__0x2C__failAsOperator() public revert__NuggftV1Swap__setUp {
    //     (uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

    //     uint96 value = 1 ether;

    //     forge.vm.startPrank(users.dee);
    //     {
    //         nuggft.setApprovalForAll(users.dennis, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_2C');
    //         nuggft.sell(tokenId, itemId, value);
    //     }
    //     forge.vm.stopPrank();
    // }

    function test__revert__NuggftV1Swap__0xA2__sell__item__failAsNotOperator() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

        uint96 value = 1 ether;

        forge.vm.startPrank(users.dennis);
        {
            forge.vm.expectRevert(hex"7e863b48_A2");
            nuggft.sell(tokenId, itemId, value);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:D] - sell - "cannot sell two of same item at same time" @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:E] - expect.balance().stopClaimerIsWinnerOrLoser - "invalid offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0xA5__successPrevSwapperCanClaimAfterNewSwapHasStarted() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 floor) = scenario_mac_has_sold_a_token_dee_sold();

        expect.claim().from(users.dee).exec(tokenId, users.dee);
    }

    function test__revert__NuggftV1Swap__0xA5__failNoOffer() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

        expect.claim().from(users.charlie).err(0xA5).exec(tokenId, users.charlie);
    }

    function test__revert__NuggftV1Swap__0xA5__successAsLeader() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

        expect.claim().from(users.mac).exec(tokenId, users.mac);
    }

    function test__revert__NuggftV1Swap__0xA5__successAsOwner() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

        expect.claim().from(users.dee).exec(tokenId, users.dee);
    }

    // function test__revert__NuggftV1Swap__0xA5__failAsOperator() public revert__NuggftV1Swap__setUp {
    //     uint24 tokenId = scenario_dee_has_sold_a_token_and_mac_can_claim();

    //     forge.vm.startPrank(users.mac);
    //     {
    //         nuggft.setApprovalForAll(users.dennis, true);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_A5');
    //         nuggft.claim(array.b24(tokenId));
    //     }
    //     forge.vm.stopPrank();
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:F] - offer - "sell must be total"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__0xA4__successOfferInActiveSwap() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 eth) = scenario_dee_has_sold_a_token_and_mac_has_offered();

        uint96 value = eth + 1 ether;

        expect.offer().from(users.charlie).exec{value: value}(tokenId);
    }

    function test__revert__NuggftV1Swap__0xA4__failOfferInOldSwap() public revert__NuggftV1Swap__setUp {
        (uint24 tokenId, uint96 eth) = scenario_dee_has_sold_a_token_and_mac_has_offered();

        jumpSwap();

        uint96 value = eth + 1 ether;

        expect.offer().from(users.charlie).err(0xA4).exec{value: value}(tokenId);
    }

    function test__revert__NuggftV1Swap__0xA0__failOfferInFutureSwap() public revert__NuggftV1Swap__setUp {
        uint24 tokenId = nuggft.epoch() + 1;

        uint96 value = 1 ether;

        expect.offer().from(users.charlie).err(0x65).exec{value: value}(tokenId);
    }
}

// @todo - make sure eth ends up where we want it
