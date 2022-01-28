//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import {expectClaim} from './claim.sol';
import {expectOffer} from './offer.sol';
import {expectBalance} from './balance.sol';
import {expectStake} from './stake.sol';
import {expectSell} from './sell.sol';
import {expectMint} from './mint.sol';

import {RiggedNuggft} from '../NuggftV1.test.sol';

contract Expect {
    expectClaim public claim;
    expectOffer public offer;
    expectBalance public balance;
    expectStake public stake;
    expectSell public sell;
    expectMint public mint;

    constructor(RiggedNuggft nuggft_) {
        global.set('Expect', address(this));

        claim = new expectClaim(nuggft_);
        offer = new expectOffer(nuggft_);
        balance = new expectBalance(nuggft_);
        stake = new expectStake(nuggft_);
        sell = new expectSell(nuggft_);
        mint = new expectMint(nuggft_);
    }
}
