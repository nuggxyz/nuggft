// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {IDotnuggV1Safe} from "../dotnugg/IDotnuggV1Safe.sol";

interface INuggftV1Proof {
    event Rotate(uint160 indexed tokenId, bytes32 proof);

    event Mint(uint160 indexed tokenId, uint96 value, bytes32 proof, bytes32 stake, bytes32 agency);

    function mint(uint160 tokenId) external payable;

    function trustedMint(uint160 tokenId, address to) external payable;

    function dotnuggV1() external view returns (IDotnuggV1Safe);

    // prettier-ignore
    function rotate(uint160 tokenId, uint8[] calldata from, uint8[] calldata to) external;

    function proofOf(uint160 tokenId) external view returns (uint256);

    function imageURI(uint256 tokenId) external view returns (string memory);

    function itemURI(uint256 itemId) external view returns (string memory);

    function featureLength(uint8 itemId) external view returns (uint8);
}
