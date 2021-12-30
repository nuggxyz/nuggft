// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IDotnuggV1Metadata {
    struct Memory {
        uint256 version;
        uint256 renderedAt;
        string name;
        string desc;
        address owner;
        uint256 tokenId;
        uint256 proof;
        uint8[] ids;
        uint8[] extras;
        uint8[] xovers;
        uint8[] yovers;
        string[] labels;
    }
}
