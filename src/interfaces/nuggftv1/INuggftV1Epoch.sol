// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface INuggftV1Epoch {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    event Genesis(uint256 blocknum, uint32 interval, uint24 offset);

    function epoch() external view returns (uint24 res);
}
