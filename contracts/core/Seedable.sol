// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/ISeedable.sol';
import '../libraries/SeedMath.sol';
import './Epochable.sol';

/**
 * @title Seedable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice enables children contracts to break themselves into epochs based on block number
 * @dev also enables storage of blockhash for a given epoch
 */
abstract contract Seedable is ISeedable, Epochable {
    using SeedMath for bytes32;

    mapping(uint256 => bytes32) private _seeds;

    constructor() {}

    /**
     * @notice gets unique base based on given epoch and converts encoded bytes to object that can be merged
     * Note: by using the block hash no one knows what a nugg will look like before it's epoch.
     * We considered making this harder to manipulate, but we decided that if someone were able to
     * pull it off and make their own custom nugg, that would be really fucking cool.
     */
    function calculateCurrentSeed() public view override returns (bytes32 res) {
        uint256 num = blocknumFromId(currentEpochId()) - 1;
        res = blockhash(num);
        require(res != 0, 'EPC:SBL');
        res = keccak256(abi.encodePacked(res, num));
    }

    /**
     * @dev
     * @return
     */
    function getSeed(uint256 id) public view override returns (bytes32 res) {
        if (seedExists(id)) return _seeds[id];
        else if (currentEpochId() == id) return calculateCurrentSeed();
        else require(false, 'SEED:GET:0');
    }

    function seedExists(uint256 id) public view override returns (bool res) {
        return _seeds[id] != 0;
    }

    // /**
    //  * @dev external wrapper for internal _seeds
    //  */
    // function seeds(uint256 id) external view override returns (bytes32 res) {
    //     res = _seeds[id];
    // }

    /**
     * @dev
     * @return
     */
    function setSeed() internal {
        require(seedExists(currentEpochId()), 'SEED:SET:0');
        _seeds[currentEpochId()] = calculateCurrentSeed();
    }
}
