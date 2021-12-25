// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Data} from './IDotnuggV1Data.sol';

interface IDotnuggV1Storage {
    function storeFiles(uint8 feature, uint256[][] calldata data) external returns (uint8 amount);
}
