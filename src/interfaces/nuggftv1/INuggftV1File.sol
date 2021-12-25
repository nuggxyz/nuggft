// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC721Metadata, IERC165} from '../IERC721.sol';

import {IDotnuggV1Implementer} from '../dotnuggv1/IDotnuggV1Implementer.sol';

interface INuggftV1File is IERC721Metadata, IDotnuggV1Implementer {}
