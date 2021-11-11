// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/ISeedable.sol';
import '../libraries/SeedMath.sol';

/**
 * @title Seedable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice enables children contracts to break themselves into epochs based on block number
 * @dev also enables storage of blockhash for a given epoch
 */
abstract contract Seedable is ISeedable {
    using SeedMath for bytes32;

    mapping(uint256 => bytes32) private _seeds;

    constructor() {}

    /**
     * @dev
     * @return
     */
    function getSeed(uint256 id) public view override returns (bytes32 res) {
        require(seedExists(id), 'SEED:GET:0');
        res = _seeds[id];
    }

    function seedExists(uint256 id) public view override returns (bool res) {
        return _seeds[id] != 0;
    }

    /**
     * @dev external wrapper for internal _seeds
     */
    function seeds(uint256 id) external view override returns (bytes32 res) {
        res = _seeds[id];
    }

    /**
     * @dev
     * @return
     */
    function setSeed(uint256 id, bytes32 seed) internal {
        require(!seedExists(id), 'SEED:SET:0');
        _seeds[id] = seed;
    }
}
