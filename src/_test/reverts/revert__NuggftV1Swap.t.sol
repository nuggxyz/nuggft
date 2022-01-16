// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';

contract revert__NuggftV1Swap is NuggftV1Test {
    using SafeCast for uint96;

    using UserTarget for address;

    uint32 epoch;

    uint160 tokenId;
    uint96 floor;
    uint16 itemId;

    uint96 eth;

    uint160 charliesTokenId;

    uint96 MIN = 10 gwei;

    int96 MININT = int96(int256(uint256(MIN)));

    function setUp() public {
        reset();
        fvm.roll(15000);

        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:0] - delegate - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_0__successAsSelf() public {
        uint96 value = 30 * 10**16;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////

    // function test__revert__NuggftV1Swap__S_0__successAsOperator() public {
    //     uint96 value = 30 * 10**16;

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.setApprovalForAll(_nuggft, users.dennis);
    //     }
    //     forge.vm.stopPrank();

    //     forge.vm.startPrank(users.dennis);
    //     {
    //         forge.vm.deal(users.dennis, value);
    //         nuggft.delegate(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    ///////////////////////////////////////////////////////////////////////

    // function test__revert__NuggftV1Swap__S_0__failAsNotOperator() public {
    //     _nuggft.shouldFail('S:0', dennis, delegate(epoch), 30 * 10**16);
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:1] - delegate - "msg.value >= minimum offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_1__successWithExactMinOffer() public {
        uint96 value = MIN;

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(value, 1, dir.up);

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, MIN);
            nuggft.delegate{value: MIN}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_1__successWithHigherMinOffer() public {
        uint96 value = MIN + 1;

        expectBalChange(users.frank, value, dir.down);
        expectBalChange(_nuggft, value, dir.up);
        expectStakeChange(value, 1, dir.up);

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, MIN + 1);
            nuggft.delegate{value: MIN + 1}(tokenId);
        }
        forge.vm.stopPrank();

        check();
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_1__failWithOneWeiLessThanMin() public {
        tokenId = nuggft.epoch();

        uint96 value = MIN - 1;

        forge.vm.startPrank(users.frank);
        {
            forge.vm.deal(users.frank, value);
            forge.vm.expectRevert('S:1');
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_1__failWithZero() public {
        tokenId = nuggft.epoch();

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
        (tokenId, floor) = scenario_dee_has_swapped_a_token();

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

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_R__successWithOwnerAfterSomeoneElseDelegates() public {
        (tokenId, floor) = scenario_dee_has_swapped_a_token();

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

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_R__failWithOwnerOnCommit() public {
        (tokenId, floor) = scenario_dee_has_swapped_a_token();

        _nuggft.shouldFail('S:R', dee, delegate(tokenId), floor + 1 ether * 2);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3b] - delegate - "if not minting, offerer must claim previous offers for the specific token"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__S_R__successWithUserWithNoPrevClaim() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

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

    ///////////////////////////////////////////////////////////////////////

    // LOL - MASSIVE bug found with this test
    function test__revert__NuggftV1Swap__S_R__successWithPrevClaimUserAfterClaiming() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        uint96 value = floor + 1 ether;

        forge.vm.deal(users.dee, value);

        forge.vm.startPrank(users.dee);
        {
            nuggft.claim(tokenId);
            nuggft.delegate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_R__failWtihUserWithPrevClaim() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

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
        tokenId = scenario_mac_has_claimed_a_token_dee_swapped();

        _nuggft.shouldFail('S:4', frank, delegate(tokenId), 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_4__failWithNonexistantToken() public {
        _nuggft.shouldFail('S:4', frank, delegate(50000), 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_4__successWithSwap() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        _nuggft.shouldPass(dee, claim(tokenId));

        _nuggft.shouldPass(dee, delegate(tokenId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:5] - delegate - "if commiting, msg.value must be >= total eth per share"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_5__failWithVeryHighEPS() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        _nuggft.shouldPass(frank, mint(1500), 50 ether);

        _nuggft.shouldFail('S:5', frank, delegate(tokenId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_5__successWithLowEPS() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        _nuggft.shouldPass(frank, mint(1500), floor + .5 ether);

        _nuggft.shouldPass(frank, delegate(tokenId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:6] - delegateItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__S_6__successAsOwnerOfBuyerTokenId() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        _nuggft.shouldPass(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_6__successAsOperator() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        _nuggft.shouldPass(charlie, setApprovalForAll(address(mac), true));

        _nuggft.shouldFail('S:6', mac, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_6__failAsNotOperator() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        _nuggft.shouldFail('S:6', mac, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:7] - delegateItem - "offerer should not be owner of swap"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_7__successWithNotOwner() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        _nuggft.shouldPass(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_7__successWithSameUserDifferentToken() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        uint160 tokenId2 = scenario_dee_has_a_token_2();

        _nuggft.shouldPass(dee, delegateItem(tokenId2, tokenId, itemId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_7__failWithUserAndOwningToken() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        _nuggft.shouldFail('S:7', dee, delegateItem(tokenId, tokenId, itemId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:8] - claim - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__NuggftV1Swap__S_8__successAsSelf() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        _nuggft.shouldPass(mac, claim(tokenId));
    }

    ///////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:9] - claimItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_9__successAsOwnerOfBuyerTokenId() public {
        (charliesTokenId, tokenId, itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        _nuggft.shouldPass(charlie, claimItem(charliesTokenId, tokenId, itemId));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_9__failAsOperator() public {
        (charliesTokenId, tokenId, itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        _nuggft.shouldPass(charlie, setApprovalForAll(address(mac), true));

        _nuggft.shouldFail('S:9', mac, claimItem(charliesTokenId, tokenId, itemId));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_9__failAsNotOperator() public {
        (charliesTokenId, tokenId, itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        _nuggft.shouldFail('S:9', mac, claimItem(charliesTokenId, tokenId, itemId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:A] - swap - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_A__successAsSelf() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        _nuggft.shouldPass(dee, swap(tokenId, 2 ether));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_A__failsAsOperator() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        _nuggft.shouldPass(dee, setApprovalForAll(address(dennis), true));

        _nuggft.shouldFail('S:A', dennis, swap(tokenId, 2 ether));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_A__failAsNotOperator() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        _nuggft.shouldFail('S:A', dennis, swap(tokenId, 2 ether));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:B] - swap - "floor >= eps"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_B__successWithEqualEPS() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.eps();

        _nuggft.shouldPass(dee, swap(tokenId, floor));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_B__successWithOneWeiTooHigh() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.eps();

        _nuggft.shouldPass(dee, swap(tokenId, floor + 1));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__NuggftV1Swap__S_B__revertWithOneWeiTooLow() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.eps();

        _nuggft.shouldFail('S:B', dee, swap(tokenId, floor - 1));
    }

    function test__revert__NuggftV1Swap__S_B__revertWithZero() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        _nuggft.shouldFail('S:B', dee, swap(tokenId, 0));
    }

    function test__revert__NuggftV1Swap__S_B__revertWithHalfFloor() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.eps();

        _nuggft.shouldFail('S:B', dee, swap(tokenId, floor / 2));
    }

    function test__revert__NuggftV1Swap__S_B__successWithWayTooHigh() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.eps();

        _nuggft.shouldPass(dee, swap(tokenId, floor + 30 ether));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:C] - swapItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_C__successAsOwnerOfBuyerTokenId() public {
        (tokenId, itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        _nuggft.shouldPass(dee, swapItem(tokenId, itemId, 1 ether));
    }

    function test__revert__NuggftV1Swap__S_C__failAsOperator() public {
        (tokenId, itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        _nuggft.shouldPass(dee, setApprovalForAll(address(dennis), true));

        _nuggft.shouldFail('S:C', dennis, swapItem(tokenId, itemId, 1 ether));
    }

    function test__revert__NuggftV1Swap__S_C__failAsNotOperator() public {
        (tokenId, itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        _nuggft.shouldFail('S:C', dennis, swapItem(tokenId, itemId, 1 ether));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:D] - swapItem - "cannot sell two of same item at same time" @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:E] - checkClaimerIsWinnerOrLoser - "invalid offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_E__successPrevSwapperCanClaimAfterNewSwapHasStarted() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        // dee got the token here
        _nuggft.shouldPass(dee, claim(tokenId));
    }

    function test__revert__NuggftV1Swap__S_E__failNoOffer() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        // dee got the token here
        _nuggft.shouldFail('S:E', charlie, claim(tokenId));
    }

    function test__revert__NuggftV1Swap__S_E__successAsLeader() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        // dee got the token here
        _nuggft.shouldPass(mac, claim(tokenId));
    }

    function test__revert__NuggftV1Swap__S_E__successAsOwner() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        // dee got the token here
        _nuggft.shouldPass(dee, claim(tokenId));
    }

    function test__revert__NuggftV1Swap__S_E__failAsOperator() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        _nuggft.shouldPass(mac, setApprovalForAll(address(dennis), true));

        _nuggft.shouldFail('S:E', dennis, claim(tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:F] - offer - "swap must be total"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Swap__S_F__successOfferInActiveSwap() public {
        (tokenId, eth) = scenario_dee_has_swapped_a_token_and_mac_has_delegated();

        // dee got the token here
        _nuggft.shouldPass(charlie, delegate(tokenId), eth + 1 ether);
    }

    function test__revert__NuggftV1Swap__S_F__failOfferInOldSwap() public {
        (tokenId, eth) = scenario_dee_has_swapped_a_token_and_mac_has_delegated();

        fvm.roll(2000);

        // dee got the token here
        _nuggft.shouldFail('S:F', charlie, delegate(tokenId), eth + 1 ether);
    }

    function test__revert__NuggftV1Swap__S_F__failOfferInFutureSwap() public {
        // dee got the token here
        _nuggft.shouldFail('S:4', charlie, delegate(50000), 1 ether);
    }
}

// @todo - make sure eth ends up where we want it
