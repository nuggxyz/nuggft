// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {ShiftLib} from '../libraries/ShiftLib.sol';

/// @notice abstracts all the logic for converting the proof between a the uint256 which is stored in
/// in state and the the 4 uint8 arrays thaconsists off.
/// @dev Explain to a developer any extra details
/// @dev itemIds are externally 16 bits, but here there are referenced as 8 bit ids in one of 8 indexs
/// where the id is the position the item exists in the file storage, and the index is the feature id
/// @dev there is not check - but dotnugg v1 only allows for max 63 for size, so anchor overrides should
/// reflect this.
/// @dev pushing and pulling is only set up for the extra array, so the user must manage their default array
/// by passing through the extra array - this is to reduce complexity
/// @dev see the dotnugg specification for more clarificaiton on the values used here
///
///  uint256 bit allocation of proof "state" variable:

///
library NuggftV1ProofType {
    /// @notice converts the proof state into a human readable form
    /// @dev fully parses the proof from a uint256 to 4 uint8 arrays
    /// @param state -> the uint256 proof state
    /// @return proof -> the uint256 proof state
    /// @return defaultIds -> the modifed uint256 proof state
    /// @return extraIds -> the modifed uint256 proof state
    /// @return xOverrides -> the modifed uint256 proof state
    /// @return yOverrides -> the modifed uint256 proof state
    // function fullProof(uint256 state)
    //     internal
    //     pure
    //     returns (
    //         uint256 proof,
    //         uint8[] memory defaultIds,
    //         uint8[] memory extraIds,
    //         uint8[] memory xOverrides,
    //         uint8[] memory yOverrides
    //     )
    // {
    //     proof = state;
    //     defaultIds = ShiftLib.getArray(state, 0);
    //     extraIds = ShiftLib.getArray(state, 64);
    //     xOverrides = ShiftLib.getArray(state, 128);
    //     yOverrides = ShiftLib.getArray(state, 192);
    // }
    /// @notice sets an item to the extra array
    /// @dev extra array must be empty at the feature positon being added to
    /// @param state -> the uint256 proof state
    /// @param itemId -> the itemId being added
    /// @return res -> the modifed uint256 proof state
    // function pushToExtra(uint256 state, uint16 itemId) internal pure returns (uint256 res) {
    //     uint8[] memory arr = ShiftLib.getArray(state, 64);
    //     (uint8 feat, uint8 pos) = parseItemId(itemId);
    //     require(arr[feat] == 0, 'P:D');
    //     arr[feat] = pos;
    //     res = ShiftLib.setArray(state, 64, arr);
    // }
    /// / @notice removes an item from the extra array
    // / @dev extra array must NOT be empty at the feature positon being removed
    // / @dev the extra array must have that specific feature in that postion
    // / @param state -> the uint256 proof state
    // / @param itemId -> the itemId being removed
    // / @return res -> the modifed uint256 proof state
    // function pullFromExtra(uint256 state, uint16 itemId) internal pure returns (uint256 res) {
    //     uint8[] memory arr = ShiftLib.getArray(state, 64);
    //     (uint8 feat, uint8 pos) = parseItemId(itemId);
    //     require(feat != 0, 'P:F');
    //     require(arr[feat] == pos, 'P:E');
    //     arr[feat] = 0;
    //     res = ShiftLib.setArray(state, 64, arr);
    // }
    /// @notice updates the x and y override arrays
    /// @dev all must be set at once
    /// @param state -> the uint256 proof state
    /// @param xOverrides -> uint8 array of new x overrides
    /// @param yOverrides -> uint8 array of new x overrides
    /// @return res -> the modifed uint256 proof state
    // function setNewAnchorOverrides(
    //     uint256 state,
    //     uint8[] memory xOverrides,
    //     uint8[] memory yOverrides
    // ) internal pure returns (uint256 res) {
    //     res = ShiftLib.setArray(state, 128, xOverrides);
    //     res = ShiftLib.setArray(res, 192, yOverrides);
    // }
    /// @notice clears the anchor overrides for a specific feature
    /// @dev this should be called each time an item is added or removed from a feature
    /// @param state -> the uint256 proof state
    /// @param feature -> the feature to switch items for
    /// @return res -> the modifed uint256 proof state
    // function clearAnchorOverridesForFeature(uint256 state, uint8 feature) internal pure returns (uint256 res) {
    //     uint8[] memory x = ShiftLib.getArray(state, 128);
    //     uint8[] memory y = ShiftLib.getArray(state, 192);
    //     y[feature] = 0;
    //     x[feature] = 0;
    //     res = ShiftLib.setArray(state, 128, x);
    //     res = ShiftLib.setArray(res, 192, y);
    // }
}
