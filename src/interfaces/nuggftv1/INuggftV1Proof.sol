// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface INuggftV1Proof {
    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                             STATE CHANGING
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function rotate(
        uint160 tokenId,
        uint8 index0,
        uint8 index1
    ) external;

    function anchor(
        uint160 tokenId,
        uint16 itemId,
        uint256 x,
        uint256 y
    ) external;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                               VIEW FUNCTIONS
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function proofOf(uint160 tokenId) external view returns (uint256);

    function proofToDotnuggMetadata(uint160 tokenId)
        external
        view
        returns (
            uint256 proof,
            uint8[] memory defaultIds,
            uint8[] memory overxs,
            uint8[] memory overys
        );
}
