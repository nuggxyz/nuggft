// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Token} from './INuggftV1Token.sol';
import {INuggftV1Stake} from './INuggftV1Stake.sol';
import {INuggftV1Proof} from './INuggftV1Proof.sol';
import {INuggftV1File} from './INuggftV1File.sol';
import {INuggftV1Swap} from './INuggftV1Swap.sol';
import {INuggftV1Loan} from './INuggftV1Loan.sol';
import {INuggftV1Epoch} from './INuggftV1Epoch.sol';

interface INuggftV1 is INuggftV1Token, INuggftV1Stake, INuggftV1Proof, INuggftV1File, INuggftV1Swap, INuggftV1Loan, INuggftV1Epoch {}
