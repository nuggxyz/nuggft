// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IProofExternal {
    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  EVENTS
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    event SetProof(uint160 tokenId, uint256 proof, uint8[] items);
    event PopItem(uint160 tokenId, uint256 proof, uint16 itemId);
    event PushItem(uint160 tokenId, uint256 proof, uint16 itemId);
    event RotateItem(uint160 tokenId, uint256 proof, uint8 feature);
    event SetAnchorOverrides(uint160 tokenId, uint256 proof, uint8[] xs, uint8[] ys);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                             STATE CHANGING
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function rotateFeature(uint160 tokenId, uint8 feature) external;

    function setOverrides(
        uint160 tokenId,
        uint8[] memory xs,
        uint8[] memory ys
    ) external;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                               VIEW FUNCTIONS
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function proofOf(uint160 tokenId) external view returns (uint256);

    function parsedProofOf(uint160 tokenId)
        external
        view
        returns (
            uint256 proof,
            uint8[] memory defaultIds,
            uint8[] memory extraIds,
            uint8[] memory overxs,
            uint8[] memory overys
        );
}
