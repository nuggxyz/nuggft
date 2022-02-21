// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {IDotnuggV1Safe} from './IDotnuggV1Safe.sol';

interface IDotnuggV1 is IDotnuggV1Safe {
    function register(bytes[] calldata input) external returns (IDotnuggV1Safe proxy);
}
