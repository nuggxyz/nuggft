// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import {IERC1155Metadata_URI, IERC1155} from "@nuggft-v1-core/src/interfaces/IERC1155.sol";

// prettier-ignore
interface IxNuggftV1 is IERC1155Metadata_URI, IERC1155 {
    function imageURI(uint256 tokenId) external view returns (string memory);

    function imageSVG(uint256 tokenId) external view returns (string memory);

    function featureSupply(uint8 itemId) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function rarity(uint256 tokenId) external view returns (uint16 res);

    function iloop() external view returns (bytes memory res);

    function tloop() external view returns (bytes memory res);

    function sloop() external view returns (bytes memory res);

    function floop(uint24 tokenId) external view returns (uint16[16] memory arr);

    function ploop(uint24 tokenId) external view returns (string memory);

	function eloop() external view returns (bytes memory res) ;

    function transferBatch(uint256 proof, address from, address to) external payable;

    function transferSingle(uint256 itemId, address from, address to) external payable;
}
