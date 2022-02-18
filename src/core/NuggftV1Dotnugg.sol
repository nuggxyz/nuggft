// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {IDotnuggV1Safe} from '../interfaces/dotnugg/IDotnuggV1Safe.sol';

import {IDotnuggV1} from '../interfaces/dotnugg/IDotnuggV1.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {INuggftV1Dotnugg} from '../interfaces/nuggftv1/INuggftV1Dotnugg.sol';
import {CastLib} from '../libraries/CastLib.sol';
import {NuggftV1Token} from './NuggftV1Token.sol';

import {NuggftV1Trust} from './NuggftV1Trust.sol';

/// @custom:testing test each function
abstract contract NuggftV1Dotnugg is NuggftV1Token, NuggftV1Trust {
    IDotnuggV1Safe public immutable dotnuggV1Safe;

    constructor(address dotnugg, bytes[] memory nuggs) {
        dotnuggV1Safe = IDotnuggV1(dotnugg).register(nuggs);
    }
}
