// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IDotnuggV1Metadata {
    struct Memory {
        uint8[] ids;
        uint8[] xovers;
        uint8[] yovers;
        uint256 version;
        address implementer;
        uint256 artifactId;
        string[] labels;
        string[] styles;
        string background;
        bytes data;
    }
}
