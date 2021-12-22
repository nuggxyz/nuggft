// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ITokenExternal} from './nuggft/ITokenExternal.sol';
import {ISwapExternal} from './nuggft/ISwapExternal.sol';
import {IProofExternal} from './nuggft/IProofExternal.sol';
import {IFileExternal} from './nuggft/IFileExternal.sol';
import {IStakeExternal} from './nuggft/IStakeExternal.sol';
import {ILoanExternal} from './nuggft/ILoanExternal.sol';
import {IEpochExternal} from './nuggft/IEpochExternal.sol';
import {ITrustExternal} from './nuggft/ITrustExternal.sol';

interface INuggFT is
    ISwapExternal,
    ITokenExternal,
    IStakeExternal,
    ILoanExternal,
    IProofExternal,
    IFileExternal,
    IEpochExternal,
    ITrustExternal
{}
