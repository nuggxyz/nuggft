// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "../../../NuggftV1.test.sol";

abstract contract revert__claim__0x67 is NuggftV1Test {
    using NuggftV1AgentType for uint256;

    uint24 TOKEN_FOR_SALE = 500;

    modifier revert__claim__0x67_setUp() {
        expect.mint().from(users.frank).exec{value: 1 ether}(TOKEN_FOR_SALE);

        expect.sell().from(users.frank).exec(TOKEN_FOR_SALE, 2 ether);

        jump(3500);
        _;
    }

    function test__revert__claim__0x67__pass__mintingToken__winnerClaimingAfterSwapIsOver() public revert__claim__0x67_setUp globalDs {
        uint24 tokenId = nuggft.epoch();

        expect.offer().from(users.dee).exec{value: nuggft.msp()}(tokenId);

        jump(tokenId + 1);

        expect.claim().from(users.dee).exec(lib.sarr160(tokenId), lib.sarrAddress(users.dee));
    }

    function test__revert__claim__0x67__fail__mintingToken__winnerClaimingDuringMintEpoch() public revert__claim__0x67_setUp globalDs {
        uint24 tokenId = nuggft.epoch();

        expect.globalFrom(users.dee);

        expect.offer().g().exec{value: nuggft.msp()}(tokenId);

        expect.claim().err(0x67).g().exec(lib.sarr160(tokenId), lib.sarrAddress(users.dee));
    }

    function test__revert__claim__0x67__fail__sellingToken__winnerClaimingDuringInitialEpoch() public revert__claim__0x67_setUp globalDs {
        expect.globalFrom(users.dee);

        expect.offer().g().exec{value: nuggft.vfo(users.dee, TOKEN_FOR_SALE)}(TOKEN_FOR_SALE);

        expect.claim().err(0x67).g().exec(lib.sarr160(TOKEN_FOR_SALE), lib.sarrAddress(users.dee));
    }

    function test__revert__claim__0x67__fail__sellingToken__winnerClaimingDuringFinalEpoch() public revert__claim__0x67_setUp globalDs {
        expect.globalFrom(users.dee);

        expect.offer().g().exec{value: nuggft.vfo(users.dee, TOKEN_FOR_SALE)}(TOKEN_FOR_SALE);

        uint24 finalEpoch = nuggft.agency(TOKEN_FOR_SALE).epoch();

        jump(finalEpoch);

        expect.claim().err(0x67).g().exec(lib.sarr160(TOKEN_FOR_SALE), lib.sarrAddress(users.dee));
    }

    function test__revert__claim__0x67__pass__sellingToken__winnerClaimingAfterSwapIsOver() public revert__claim__0x67_setUp globalDs {
        expect.globalFrom(users.dee);

        expect.offer().g().exec{value: nuggft.vfo(users.dee, TOKEN_FOR_SALE)}(TOKEN_FOR_SALE);

        uint24 finalEpoch = nuggft.agency(TOKEN_FOR_SALE).epoch();

        jump(finalEpoch + 1);

        expect.claim().g().exec(lib.sarr160(TOKEN_FOR_SALE), lib.sarrAddress(users.dee));
    }
}
