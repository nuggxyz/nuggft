// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Metadata as Metadata} from './IDotnuggV1Metadata.sol';

interface IDotnuggV1File {
    struct Raw {
        uint256[][] file;
        Metadata.Memory metadata;
    }

    struct Processed {
        uint256[] file;
        Metadata.Memory metadata;
    }

    struct Compressed {
        uint256[] file;
        Metadata.Memory metadata;
    }
}
