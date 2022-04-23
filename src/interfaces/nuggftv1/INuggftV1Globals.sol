// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {IDotnuggV1Safe} from "../dotnugg/IDotnuggV1Safe.sol";

interface INuggftV1Globals {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    event Genesis(uint256 blocknum, uint32 interval, uint24 offset, uint8 intervalOffset, uint24 early, address dotnugg, address xnuggftv1, bytes32 stake);

    function genesis() external view returns (uint256 res);

    function stake() external view returns (uint256 res);

    function agency(uint24 tokenId) external view returns (uint256 res);

    function proof(uint24 tokenId) external view returns (uint256 res);

    function migrator() external view returns (address res);

    function early() external view returns (uint24 res);

    function dotnuggv1() external view returns (IDotnuggV1Safe);
}
