// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Implementer} from '../dotnuggv1/IDotnuggV1Implementer.sol';
import {IDotnuggV1ImplementerMetadata} from '../dotnuggv1/IDotnuggV1ImplementerMetadata.sol';

interface INuggftV1Dotnugg is IDotnuggV1Implementer, IDotnuggV1ImplementerMetadata {}
