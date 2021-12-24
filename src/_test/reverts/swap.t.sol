// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';
import {SafeCast} from '../fixtures/NuggFather.fix.sol';

contract revertTest__swap is NuggFatherFix {
    using SafeCast for uint96;

    uint32 epoch;

    uint160 tokenId;
    uint96 floor;
    uint16 itemId;

    uint96 eth;

    uint160 charliesTokenId;

    function setUp() public {
        reset();
        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:0] - delegate - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_0__successAsSelf() public {
        nuggft_call(frank, delegate(address(frank), epoch), 30 * 10**16);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_0__successAsOperator() public {
        nuggft_call(frank, setApprovalForAll(address(dennis), true));

        nuggft_call(dennis, delegate(address(frank), epoch), 30 * 10**16);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_0__failAsNotOperator() public {
        nuggft_revertCall('S:0', dennis, delegate(address(frank), epoch), 30 * 10**16);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:1] - delegate - "msg.value >= minimum offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    uint96 constant MIN = 100 * 10**13;

    int96 constant MININT = 100 * 10**13;

    function test__revert__swap__S_1__successWithExactMinOffer()
        public
        changeInUserBalance(frank, -1 * MININT)
        changeInNuggftBalance(MININT)
        changeInStaked(MININT, 1)
    {
        nuggft_call(frank, delegate(address(frank), epoch), MIN);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_1__successWithHigherMinOffer()
        public
        changeInUserBalance(frank, -1 * (MININT + 1))
        changeInNuggftBalance(MININT + 1)
        changeInStaked(MININT + 1, 1)
    {
        nuggft_call(frank, delegate(address(frank), epoch), MIN + 1);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_1__failWithOneWeiLessThanMin() public {
        nuggft_revertCall('S:1', frank, delegate(address(frank), epoch), MIN - 1);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_1__failWithZero() public {
        nuggft_revertCall('S:1', frank, delegate(address(frank), epoch), 0);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3a] - delegate - "if commiting, offerer should not be owner of swap"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_R__successWithNotOwner() public {
        (tokenId, floor) = scenario_dee_has_swapped_a_token();

        wrap__revert__swap__S_R__successWithNotOwner();
    }

    function wrap__revert__swap__S_R__successWithNotOwner()
        internal
        changeInUserBalance(frank, -1 * (floor.safeInt() + 1 ether))
        changeInNuggftBalance(floor.safeInt() + 1 ether)
        changeInStaked(1 ether, 0)
    {
        nuggft_call(frank, delegate(address(frank), tokenId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_R__successWithOwnerAfterSomeoneElseDelegates() public {
        (tokenId, floor) = scenario_dee_has_swapped_a_token();

        wrap__revert__swap__S_R__successWithOwnerAfterSomeoneElseDelegates();
    }

    function wrap__revert__swap__S_R__successWithOwnerAfterSomeoneElseDelegates()
        public
        changeInUserBalance(frank, -1 * (floor.safeInt() + 1 ether))
        changeInUserBalance(dee, -1 * (floor.safeInt() + 1 ether * 2))
        changeInNuggftBalance(3 ether + floor.safeInt() * 2)
        changeInStaked(3 ether, 0)
    {
        nuggft_call(frank, delegate(address(frank), tokenId), floor + 1 ether);

        nuggft_call(dee, delegate(address(dee), tokenId), floor + 2 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_R__failWithOwnerOnCommit() public {
        (tokenId, floor) = scenario_dee_has_swapped_a_token();

        nuggft_revertCall('S:R', dee, delegate(address(dee), tokenId), floor + 1 ether * 2);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3b] - delegate - "if not minting, offerer must claim previous offers for the specific token"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__swap__S_R__successWithUserWithNoPrevClaim() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        wrap__revert__swap__S_R__successWithUserWithNoPrevClaim();
    }

    function wrap__revert__swap__S_R__successWithUserWithNoPrevClaim()
        internal
        changeInUserBalance(frank, -1 * (floor.safeInt() + 1 ether))
        changeInNuggftBalance(floor.safeInt() + 1 ether)
        changeInStaked(1 ether, 0)
    {
        nuggft_call(frank, delegate(address(frank), tokenId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    // LOL - MASSIVE bug found with this test
    function test__revert__swap__S_R__successWithPrevClaimUserAfterClaiming() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_call(dee, claim(address(dee), tokenId));

        nuggft_call(dee, delegate(address(dee), tokenId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_R__failWtihUserWithPrevClaim() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_revertCall('S:R', dee, delegate(address(dee), tokenId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:4] - delegate - "if not minting, swap data must exist"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__swap__S_4__failWithNoSwap() public {
        tokenId = scenario_mac_has_claimed_a_token_dee_swapped();

        nuggft_revertCall('S:4', frank, delegate(address(frank), tokenId), 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_4__failWithNonexistantToken() public {
        nuggft_revertCall('S:4', frank, delegate(address(frank), 50000), 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_4__successWithSwap() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_call(dee, claim(address(dee), tokenId));

        nuggft_call(dee, delegate(address(dee), tokenId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:5] - delegate - "if commiting, msg.value must be >= active eth per share"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_5__failWithVeryHighEPS() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_call(frank, mint(1500), 50 ether);

        nuggft_revertCall('S:5', frank, delegate(address(frank), tokenId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_5__successWithLowEPS() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_call(frank, mint(1500), floor + .5 ether);

        nuggft_call(frank, delegate(address(frank), tokenId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:6] - delegateItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__swap__S_6__successAsOwnerOfBuyerTokenId() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        nuggft_call(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_6__successAsOperator() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        nuggft_call(charlie, setApprovalForAll(address(mac), true));

        nuggft_call(mac, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_6__failAsNotOperator() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        nuggft_revertCall('S:6', mac, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:7] - delegateItem - "offerer should not be owner of swap"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_7__successWithNotOwner() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        nuggft_call(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_7__successWithSameUserDifferentToken() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        uint160 tokenId2 = scenario_dee_has_a_token_2();

        nuggft_call(dee, delegateItem(tokenId2, tokenId, itemId), floor + 1 ether);
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_7__failWithUserAndOwningToken() public {
        (tokenId, , itemId, floor) = scenario_dee_has_swapped_an_item();

        nuggft_revertCall('S:7', dee, delegateItem(tokenId, tokenId, itemId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:8] - claim - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__swap__S_8__successAsSelf() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        nuggft_call(mac, claim(address(mac), tokenId));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_8__successAsOperator() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        nuggft_call(mac, setApprovalForAll(address(dennis), true));

        nuggft_call(dennis, claim(address(mac), tokenId));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_8__failAsNotOperator() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        nuggft_revertCall('S:8', dennis, claim(address(frank), tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:9] - claimItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_9__successAsOwnerOfBuyerTokenId() public {
        (charliesTokenId, tokenId, itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        nuggft_call(charlie, claimItem(charliesTokenId, tokenId, itemId));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_9__successAsOperator() public {
        (charliesTokenId, tokenId, itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        nuggft_call(charlie, setApprovalForAll(address(mac), true));

        nuggft_call(mac, claimItem(charliesTokenId, tokenId, itemId));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_9__failAsNotOperator() public {
        (charliesTokenId, tokenId, itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        nuggft_revertCall('S:9', mac, claimItem(charliesTokenId, tokenId, itemId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:A] - swap - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_A__successAsSelf() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        nuggft_call(dee, swap(tokenId, 2 ether));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_A__successAsOperator() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        nuggft_call(dee, setApprovalForAll(address(dennis), true));

        nuggft_call(dennis, swap(tokenId, 2 ether));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_A__failAsNotOperator() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        nuggft_revertCall('S:A', dennis, swap(tokenId, 2 ether));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:B] - swap - "floor >= activeEthPerShare"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_B__successWithEqualEPS() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.activeEthPerShare();

        nuggft_call(dee, swap(tokenId, floor));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_B__successWithOneWeiTooHigh() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.activeEthPerShare();

        nuggft_call(dee, swap(tokenId, floor + 1));
    }

    ///////////////////////////////////////////////////////////////////////

    function test__revert__swap__S_B__revertWithOneWeiTooLow() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.activeEthPerShare();

        nuggft_revertCall('S:B', dee, swap(tokenId, floor - 1));
    }

    function test__revert__swap__S_B__revertWithZero() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        nuggft_revertCall('S:B', dee, swap(tokenId, 0));
    }

    function test__revert__swap__S_B__revertWithHalfFloor() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.activeEthPerShare();

        nuggft_revertCall('S:B', dee, swap(tokenId, floor / 2));
    }

    function test__revert__swap__S_B__successWithWayTooHigh() public {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        scenario_frank_has_a_token_and_spent_50_eth();

        floor = nuggft.activeEthPerShare();

        nuggft_call(dee, swap(tokenId, floor + 30 ether));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:C] - swapItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_C__successAsOwnerOfBuyerTokenId() public {
        (tokenId, itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        nuggft_call(dee, swapItem(tokenId, itemId, 1 ether));
    }

    function test__revert__swap__S_C__successAsOperator() public {
        (tokenId, itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        nuggft_call(dee, setApprovalForAll(address(dennis), true));

        nuggft_call(dennis, swapItem(tokenId, itemId, 1 ether));
    }

    function test__revert__swap__S_C__failAsNotOperator() public {
        (tokenId, itemId, ) = scenario_dee_has_a_token_and_can_swap_an_item();

        nuggft_revertCall('S:C', dennis, swapItem(tokenId, itemId, 1 ether));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:D] - swapItem - "cannot sell two of same item at same time" @todo
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:E] - checkClaimerIsWinnerOrLoser - "invalid offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_E__successPrevSwapperCanClaimAfterNewSwapHasStarted() public {
        (tokenId, floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        // dee got the token here
        nuggft_call(dee, claim(address(dee), tokenId));
    }

    function test__revert__swap__S_E__failNoOffer() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        // dee got the token here
        nuggft_revertCall('S:E', charlie, claim(address(charlie), tokenId));
    }

    function test__revert__swap__S_E__successAsLeader() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        // dee got the token here
        nuggft_call(mac, claim(address(mac), tokenId));
    }

    function test__revert__swap__S_E__successAsOwner() public {
        tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        // dee got the token here
        nuggft_call(dee, claim(address(dee), tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:F] - offer - "swap must be active"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_F__successOfferInActiveSwap() public {
        (tokenId, eth) = scenario_dee_has_swapped_a_token_and_mac_has_delegated();

        // dee got the token here
        nuggft_call(charlie, delegate(address(charlie), tokenId), eth + 1 ether);
    }

    function test__revert__swap__S_F__failOfferInOldSwap() public {
        (tokenId, eth) = scenario_dee_has_swapped_a_token_and_mac_has_delegated();

        fvm.roll(2000);

        // dee got the token here
        nuggft_revertCall('S:F', charlie, delegate(address(charlie), tokenId), eth + 1 ether);
    }

    function test__revert__swap__S_F__failOfferInFutureSwap() public {
        // dee got the token here
        nuggft_revertCall('S:4', charlie, delegate(address(charlie), 50000), 1 ether);
    }
}

// @todo - make sure eth ends up where we want it
