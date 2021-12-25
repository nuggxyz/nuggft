// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC721Metadata, IERC165} from '../IERC721.sol';

import {IdotnuggV1Implementer} from '../IdotnuggV1.sol';

interface INuggftV1File is IERC721Metadata, IdotnuggV1Implementer {
    function storeFiles(uint256[][] calldata data, uint8 feature) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/
}
