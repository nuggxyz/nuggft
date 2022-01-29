// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {INuggftV1Token} from './INuggftV1Token.sol';
import {INuggftV1Stake} from './INuggftV1Stake.sol';
import {INuggftV1Proof} from './INuggftV1Proof.sol';
import {INuggftV1Dotnugg} from './INuggftV1Dotnugg.sol';
import {INuggftV1Swap} from './INuggftV1Swap.sol';
import {INuggftV1Loan} from './INuggftV1Loan.sol';
import {INuggftV1Epoch} from './INuggftV1Epoch.sol';
import {INuggftV1Trust} from './INuggftV1Trust.sol';

import {IERC721Metadata} from '../IERC721.sol';

interface INuggftV1 is
    IERC721Metadata,
    INuggftV1Token,
    INuggftV1Stake,
    INuggftV1Proof,
    INuggftV1Dotnugg,
    INuggftV1Swap,
    INuggftV1Loan,
    INuggftV1Epoch,
    INuggftV1Trust
{}
