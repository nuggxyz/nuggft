// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

// prettier-ignore

interface INuggftV1Proof {

    //
    function rotate(uint160 tokenId,uint8[] calldata index0s,uint8[] calldata index1s) external;



    function proofOf(uint160 tokenId) external view returns (uint256);

    function imageURI(uint256 tokenId) external view returns (string memory res);

}
