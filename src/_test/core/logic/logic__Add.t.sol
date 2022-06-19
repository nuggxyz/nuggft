pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";

import {CastLib} from "../../helpers/CastLib.sol";

abstract contract logic__Add is NuggftV1Test {
    function test__logic__Add__cumlative() public {
        resetManual(dub6ix, (10000 * STARTING_PRICE));
        jumpStart();
        jumpSwap();

        uint96 start = nuggft.msp();

        mintHelper(mintable(0), users.frank, start);

        for (uint24 i = 1; i < 10000; i++) {
            mintHelper(mintable(i), users.frank, nuggft.msp());
        }

        console.log("proto:  ", nuggft.proto());
        console.log("shares: ", nuggft.shares());
        console.log("staked: ", nuggft.staked());

        console.log("eps:    ", nuggft.eps());
        console.log("msp:    ", nuggft.msp());
    }
}

// 1000 mints at 100 gwei -   .000094507259963891 - lol
// 1000 mints at .001 ether - .945072599688525587
//                          44.218283425255061369
// 13414249267230307
//  73.710472375425121431
// 257.489535666359851594

// .122196917593446897

// .040732305864482299

// 85829845222001755

// 40732305864482259

//       85829845222119873509
// 109940.5366172285078035201

// 1319.331456094062691824
//85903684394412377201
//.004076909426251059
