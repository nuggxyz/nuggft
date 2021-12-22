// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC721Metadata, IERC165} from '../IERC721.sol';

import {IdotnuggV1Implementer} from '../IdotnuggV1.sol';

interface IFileExternal is IERC721Metadata, IdotnuggV1Implementer {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function totalLengths() external view returns (uint8[] memory res);
}
