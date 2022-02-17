// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {IDotnuggV1Safe} from '../interfaces/dotnugg/IDotnuggV1Safe.sol';

import {IDotnuggV1} from '../interfaces/dotnuggv1/IDotnuggV1.sol';
import {IDotnuggV1Metadata} from '../interfaces/dotnuggv1/IDotnuggV1Metadata.sol';
import {IDotnuggV1Resolver} from '../interfaces/dotnuggv1/IDotnuggV1Resolver.sol';
import {IDotnuggV1Implementer} from '../interfaces/dotnuggv1/IDotnuggV1Implementer.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {INuggftV1Dotnugg} from '../interfaces/nuggftv1/INuggftV1Dotnugg.sol';
import {CastLib} from '../libraries/CastLib.sol';
import {NuggftV1Token} from './NuggftV1Token.sol';

import {NuggftV1Trust} from './NuggftV1Trust.sol';

/// @custom:testing test each function
abstract contract NuggftV1Dotnugg is NuggftV1Token, NuggftV1Trust {
    IDotnuggV1Safe public dotnuggV1Safe;
}
