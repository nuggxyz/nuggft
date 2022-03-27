pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

import {CastLib} from "../../helpers/CastLib.sol";

import {parseItemId} from "../../../libraries/DotnuggV1Lib.sol";

abstract contract logic__Add is NuggftV1Test {
    function test__logic__Add__cumlative() public {
        jumpStart();
        jumpSwap();

        uint96 start = .03 ether;

        nuggft.mint{value: start}(mintable(0));

        for (uint24 i = 1; i < 10000; i++) {
            nuggft.mint{value: nuggft.msp()}(mintable(i));
        }

        console.log("proto:  ", nuggft.proto());
        console.log("shares: ", nuggft.shares());
        console.log("staked: ", nuggft.staked());

        console.log("eps:    ", nuggft.eps());
        console.log("msp:    ", nuggft.msp());
    }
}

// 1000 mints at 100 gwei -   .000094507259963891
// 1000 mints at .001 ether - .945072599688525587
//                          44.218283425255061369
// 13414249267230307
//  73.710472375425121431
// 257.489535666359851594

// .122196917593446897

// .040732305864482299
