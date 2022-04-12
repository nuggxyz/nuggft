// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {IDotnuggV1Safe} from "../dotnugg/IDotnuggV1Safe.sol";

interface INuggftV1Proof {
    event Rotate(uint24 indexed tokenId, bytes32 proof);

    event Mint(uint24 indexed tokenId, uint96 value, bytes32 proof, bytes32 stake, bytes32 agency);

    function mint(uint24 tokenId) external payable;

    function trustedMint(uint24 tokenId, address to) external payable;

    function dotnuggV1() external view returns (IDotnuggV1Safe);

    // prettier-ignore
    function rotate(uint24 tokenId, uint8[] calldata from, uint8[] calldata to) external;

    function proofOf(uint24 tokenId) external view returns (uint256);

    function imageURI(uint256 tokenId) external view returns (string memory);

    function itemURI(uint256 itemId) external view returns (string memory);

    function featureLength(uint8 itemId) external view returns (uint8);
}
