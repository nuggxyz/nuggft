// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {IDotnuggV1Safe} from '@nuggxyz/dotnugg-v1-core/interfaces/IDotnuggV1Safe.sol';
import {IDotnuggV1} from '@nuggxyz/dotnugg-v1-core/interfaces/IDotnuggV1.sol';
import {IDotnuggV1Resolver} from '@nuggxyz/dotnugg-v1-core/interfaces/IDotnuggV1Resolver.sol';

import {INuggftV1Dotnugg} from '../interfaces/nuggftv1/INuggftV1Dotnugg.sol';

import {NuggftV1Token} from './NuggftV1Token.sol';

import {NuggftV1Trust} from './NuggftV1Trust.sol';

import {data} from '../_data/a.data.sol';

/// @custom:testing test each function
abstract contract NuggftV1Dotnugg is INuggftV1Dotnugg, NuggftV1Token, NuggftV1Trust {
    uint256 internal featureLengths;

    constructor() {}

    function lengthOf(uint8 feature) external view returns (uint8) {
        return _lengthOf(featureLengths, feature);
    }

    function _lengthOf(uint256 cache, uint8 feature) internal pure returns (uint8) {
        // return uint8(ShiftLib.get(cache, 8, feature * 8));
    }
}
