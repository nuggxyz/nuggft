// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

library SeedMath {
    /**
     * @notice turns a seed into a unique uint256 to be used in computation
     * @param seed the bytes32
     * @dev not intended to be truly random
     */
    function toUint256(bytes32 seed) internal pure returns (uint256 res) {
        return uint256(keccak256(abi.encodePacked(seed)));
    }
}
