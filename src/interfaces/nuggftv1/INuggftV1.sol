// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {INuggftV1Stake} from './INuggftV1Stake.sol';
import {INuggftV1Proof} from './INuggftV1Proof.sol';
import {INuggftV1Swap} from './INuggftV1Swap.sol';
import {INuggftV1Loan} from './INuggftV1Loan.sol';
import {INuggftV1Epoch} from './INuggftV1Epoch.sol';
import {INuggftV1Trust} from './INuggftV1Trust.sol';
import {INuggftV1ItemSwap} from './INuggftV1ItemSwap.sol';

import {IERC721Metadata, IERC721} from '../IERC721.sol';

// prettier-ignore
interface INuggftV1 is
    IERC721,
    IERC721Metadata,
    INuggftV1Stake,
    INuggftV1Proof,
    INuggftV1Swap,
    INuggftV1Loan,
    INuggftV1Epoch,
    INuggftV1Trust,
    INuggftV1ItemSwap
{


}
