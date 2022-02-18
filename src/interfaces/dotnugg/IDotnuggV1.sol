// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {IDotnuggV1Safe} from './IDotnuggV1Safe.sol';

interface IDotnuggV1 {
    function register(bytes[] calldata input) external returns (IDotnuggV1Safe proxy);
}
