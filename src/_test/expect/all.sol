//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import {expectClaim} from './claim.sol';
import {expectOffer} from './offer.sol';

abstract contract expectAll is expectClaim, expectOffer {}
