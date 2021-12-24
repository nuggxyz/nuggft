// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract revertTest__swap is NuggFatherFix {
    uint32 epoch;

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

    function test__revert__swap__S_0__successAsOperator() public {
        nuggft_call(frank, setApprovalForAll(address(dennis), true));

        nuggft_call(dennis, delegate(address(frank), epoch), 30 * 10**16);
    }

    function test__revert__swap__S_0__failAsNotOperator() public {
        nuggft_revertCall('S:0', dennis, delegate(address(frank), epoch), 30 * 10**16);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:1] - delegate - "msg.value >= minimum offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    uint96 constant MIN = 100 * 10**13;

    function test__revert__swap__S_1__successWithExactMinOffer() public {
        nuggft_call(frank, delegate(address(frank), epoch), MIN);
    }

    function test__revert__swap__S_1__successWithHigherMinOffer() public {
        nuggft_call(frank, delegate(address(frank), epoch), MIN + 1);
    }

    function test__revert__swap__S_1__failWithOneWeiLessThanMin() public {
        nuggft_revertCall('S:1', frank, delegate(address(frank), epoch), MIN - 1);
    }

    function test__revert__swap__S_1__failWithZero() public {
        nuggft_revertCall('S:1', frank, delegate(address(frank), epoch), 0);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3a] - delegate - "if not minting, offerer should not be owner of swap"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_2__successWithNotOwner() public {
        (uint160 tokenId, uint96 floor) = scenario_dee_has_swapped_a_token();

        nuggft_call(frank, delegate(address(frank), tokenId), floor + 10**18);
    }

    function test__revert__swap__S_2__failWithOwner() public {
        (uint160 tokenId, uint96 floor) = scenario_dee_has_swapped_a_token();

        nuggft_revertCall('S:3', dee, delegate(address(dee), tokenId), floor + 10**18);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:3b] - delegate - "if not minting, offerer must claim previous offers for the specific token"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__swap__S_3__successWithUserWithNoPrevClaim() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_call(frank, delegate(address(frank), tokenId), floor + 10**18);
    }

    // LOL - MASSIVE bug found with this test
    function test__revert__swap__S_3__successWithPrevClaimUserAfterClaiming() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        // dee got the token here
        nuggft_call(dee, claim(address(dee), tokenId));

        nuggft_call(dee, delegate(address(dee), tokenId), floor + 10**18);
    }

    function test__revert__swap__S_3__failWtihUserWithPrevClaim() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_revertCall('S:3', dee, delegate(address(dee), tokenId), floor + 10**18);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:4] - delegate - "if not minting, swap data must exist"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__swap__S_4__failWithNoSwap() public {
        uint160 tokenId = scenario_mac_has_claimed_a_token_dee_swapped();

        nuggft_revertCall('S:4', frank, delegate(address(frank), tokenId), 10**18);
    }

    function test__revert__swap__S_4__failWithNonexistantToken() public {
        nuggft_revertCall('S:4', frank, delegate(address(frank), 50000), 10**18);
    }

    function test__revert__swap__S_4__successWithSwap() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_call(dee, claim(address(dee), tokenId));

        nuggft_call(dee, delegate(address(dee), tokenId), floor + 10**18);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:5] - delegate - "if commiting, msg.value must be >= active eth per share"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_5__failWithVeryHighEPS() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_call(frank, mint(1500), 50 ether);

        nuggft_revertCall('S:5', frank, delegate(address(frank), tokenId), floor + 1 ether);
    }

    function test__revert__swap__S_5__successWithLowEPS() public {
        (uint160 tokenId, uint96 floor) = scenario_mac_has_swapped_a_token_dee_swapped();

        nuggft_call(frank, mint(1500), floor + .5 ether);

        nuggft_call(frank, delegate(address(frank), tokenId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:6] - delegateItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__swap__S_6__successAsOwnerOfBuyerTokenId() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        nuggft_call(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    function test__revert__swap__S_6__successAsOperator() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        nuggft_call(charlie, setApprovalForAll(address(mac), true));

        nuggft_call(mac, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    function test__revert__swap__S_6__failAsNotOperator() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        nuggft_revertCall('S:6', mac, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:7] - delegateItem - "offerer should not be owner of swap"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_7__successWithNotOwner() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 charliesTokenId = scenario_charlie_has_a_token();

        nuggft_call(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 10**18);
    }

    function test__revert__swap__S_7__successWithSameUserDifferentToken() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        uint160 tokenId2 = scenario_dee_has_a_token_2();

        nuggft_call(dee, delegateItem(tokenId2, tokenId, itemId), floor + 10**18);
    }

    function test__revert__swap__S_7__failWithUserAndOwningToken() public {
        (uint160 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_swapped_an_item();

        nuggft_revertCall('S:7', dee, delegateItem(tokenId, tokenId, itemId), floor + 10**18);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:8] - claim - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function test__revert__swap__S_8__successAsSelf() public {
        uint160 tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        nuggft_call(mac, claim(address(mac), tokenId));
    }

    function test__revert__swap__S_8__successAsOperator() public {
        uint160 tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        nuggft_call(mac, setApprovalForAll(address(dennis), true));

        nuggft_call(dennis, claim(address(mac), tokenId));
    }

    function test__revert__swap__S_8__failAsNotOperator() public {
        uint160 tokenId = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        nuggft_revertCall('S:8', dennis, claim(address(frank), tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:9] - claimItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__swap__S_9__successAsOwnerOfBuyerTokenId() public {
        (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        nuggft_call(charlie, claimItem(charliesTokenId, tokenId, itemId));
    }

    function test__revert__swap__S_9__successAsOperator() public {
        (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        nuggft_call(charlie, setApprovalForAll(address(mac), true));

        nuggft_call(mac, claimItem(charliesTokenId, tokenId, itemId));
    }

    function test__revert__swap__S_9__failAsNotOperator() public {
        (uint160 charliesTokenId, uint160 tokenId, uint16 itemId) = scenario_dee_has_swapped_an_item_and_charlie_can_claim();

        nuggft_revertCall('S:9', mac, claimItem(charliesTokenId, tokenId, itemId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:A] - swap - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:B] - swap - "floor >= activeEthPerShare"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:C] - swapItem - "msg.sender is operator for buyerTokenId"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:D] - swapItem - "cannot sell two of same item at same time"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:E] - checkClaimerIsWinnerOrLoser - "invalid offer"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [S:F] - offer - "swap must be active"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
}
