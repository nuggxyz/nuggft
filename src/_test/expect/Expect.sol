//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import {expectClaim} from './claim.sol';
import {expectOffer} from './offer.sol';
import {expectBalance} from './balance.sol';
import {expectStake} from './stake.sol';
import {expectSell} from './sell.sol';
import {expectMint} from './mint.sol';
import {expectLoan} from './loan.sol';
import {expectRebalance} from './rebalance.sol';
import {expectLiquidate} from './liquidate.sol';

import {RiggedNuggft} from '../NuggftV1.test.sol';

contract Expect {
    expectClaim public claim;
    expectOffer public offer;
    expectBalance public balance;
    expectStake public stake;
    expectSell public sell;
    expectMint public mint;
    expectLoan public loan;
    expectRebalance public rebalance;
    expectLiquidate public liquidate;

    address public _globalFrom;

    function globalFrom(address user) public {
        _globalFrom = user;
    }

    constructor(address nuggft_) {
        global.set('Expect', address(this));
        global.set('RiggedNuggft', nuggft_);

        claim = new expectClaim();
        offer = new expectOffer();
        balance = new expectBalance();
        stake = new expectStake();
        sell = new expectSell();
        mint = new expectMint();
        loan = new expectLoan();
        rebalance = new expectRebalance();
        liquidate = new expectLiquidate();
    }
}
