// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface INuggftV1Proof {
    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                             STATE CHANGING
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function rotate(
        uint160 tokenId,
        uint8[] calldata index0s,
        uint8[] calldata index1s
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
            uint8[] memory overys,
            string[] memory styles,
            string memory background
        );
}
