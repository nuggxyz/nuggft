// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

interface INuggftV1Epoch {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    event Genesis(uint256 blocknum, uint32 interval, uint24 offset, uint8 intervalOffset);

    function genesis() external view returns (uint256 res);

    function epoch() external view returns (uint24 res);
}
