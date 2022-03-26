// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

/// Error__0x74__Untrusted
/// desc: this error is thrown when the user is not someone that can receive funds for the user who owns them

abstract contract revert__claim__0x74 is NuggftV1Test {
    using NuggftV1AgentType for uint256;

    uint24 FRANKS_TOKEN = 500;

    uint24 CHARLIES_TOKEN = 501;
    uint24 DENNISS_TOKEN = 502;

    uint16 ITEM_ID;

    uint40 FRANKS_TOKEN_SELLING_ITEM_ID = 500;

    modifier revert__claim__0x74_setUp() {
        // mint required tokens
        expect.mint().from(users.frank).exec{value: 1 ether}(FRANKS_TOKEN);
        expect.mint().from(users.charlie).exec{value: 1 ether}(CHARLIES_TOKEN);
        expect.mint().from(users.dennis).exec{value: 1 ether}(DENNISS_TOKEN);

        // frank gets a sellable itemId
        ITEM_ID = uint16(nuggft.floop(FRANKS_TOKEN)[2]);
        FRANKS_TOKEN_SELLING_ITEM_ID = (uint40(ITEM_ID) << 24) | FRANKS_TOKEN;

        // frank puts the item and the nugg up for sale
        expect.sell().from(users.frank).exec(FRANKS_TOKEN, 2 ether);
        expect.sell().from(users.frank).exec(FRANKS_TOKEN, ITEM_ID, 2 ether);

        // jump to epoch 3500
        jump(3500);

        // DEE makes a LOSING NUGG offer
        expect.offer().from(users.dee).exec{value: 2.2 ether}(FRANKS_TOKEN);

        // MAC makes a WINNING NUGG offer
        expect.offer().from(users.mac).exec{value: 3 ether}(FRANKS_TOKEN);

        // CHARLIE makes a LOSING ITEM offer
        expect.offer().from(users.charlie).exec{value: 2.2 ether}(CHARLIES_TOKEN, FRANKS_TOKEN, ITEM_ID);

        // DENNIS makes a WINNING ITEM offer
        expect.offer().from(users.dennis).exec{value: 3 ether}(DENNISS_TOKEN, FRANKS_TOKEN, ITEM_ID);

        // jump to an epoch where the offer can be claimed
        jump(nuggft.epoch() + 2);
        _;
    }

    function test__revert__claim__0x74__pass__nugg__correctSenderCorrectArg() public revert__claim__0x74_setUp globalDs {
        expect.claim().from(users.mac).exec(array.s160(FRANKS_TOKEN), array.bAddress(users.mac));
    }

    function test__revert__claim__0x74__pass__item__nonWinningIncorrectSenderIncorrectArg() public revert__claim__0x74_setUp globalDs {
        expect.claim().from(users.charlie).exec(array.s160(FRANKS_TOKEN_SELLING_ITEM_ID), array.bAddress(address(uint160(CHARLIES_TOKEN))));

        expect.claim().from(users.charlie).exec(array.s160(FRANKS_TOKEN_SELLING_ITEM_ID), array.bAddress(address(uint160(DENNISS_TOKEN))));
    }

    function test__revert__claim__0x74__fail__item__userWithPendingWinningNuggClaim() public revert__claim__0x74_setUp globalDs {
        expect.claim().err(0x74).from(users.mac).exec(array.s160(FRANKS_TOKEN_SELLING_ITEM_ID), array.bAddress(users.mac));
    }

    function test__revert__claim__0x74__fail__nugg__incorrectSenderCorrectArg() public revert__claim__0x74_setUp globalDs {
        expect.claim().err(0x74).from(users.dee).exec(array.s160(FRANKS_TOKEN_SELLING_ITEM_ID), array.bAddress(users.mac));
    }

    function test__revert__claim__0x74__fail__item__nonWinningIncorrectSenderIncorrectArgIncorectUser() public revert__claim__0x74_setUp globalDs {
        expect.claim().err(0x74).from(users.dee).exec(array.s160(FRANKS_TOKEN_SELLING_ITEM_ID), array.bAddress(address(uint160(CHARLIES_TOKEN))));
    }

    // function test__revert__claim__0x74__fail__item__correctUserIncorrectNugg() public revert__claim__0x74_setUp {
    //     assert(false);
    // }

    // function test__revert__claim__0x74__pass__item__correctUserCorrectNugg() public revert__claim__0x74_setUp {
    //     assert(false);
    // }
}
