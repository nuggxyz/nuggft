// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IEpochable.sol';
import '../libraries/EpochMath.sol';

/**
 * @title Epochable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice enables children contracts to break themselves into epochs based on block number
 * @dev also enables storage of blockhash for a given epoch
 */
abstract contract Epochable is IEpochable {
    using EpochMath for uint256;

    mapping(uint256 => bytes32) private _seeds;

    uint256 private _state;

    event Genesis(uint128 interval, uint128 baseblock);

    constructor(uint128 _interval, uint128 _baseblock) {
        // _baseblock += 1;
        _state = EpochMath.encodeData(_interval, _baseblock);
        emit Genesis(_interval, _baseblock);
    }

    function ensureActiveSeed() internal {
        if (!seedExists(currentEpochId())) {
            _seeds[currentEpochId()] = currentSeed();
        }
    }

    /**
     * @dev public wrapper for internal _currentEpoch() - to save on gas
     * @inheritdoc IEpochable
     */
    function currentEpochId() public view override returns (uint48 res) {
        res = _state.getIdFromBlocknum(block.number);
    }

    /**
     * @notice gets unique base based on given epoch and converts encoded bytes to object that can be merged
     * Note: by using the block hash no one knows what a nugg will look like before it's epoch.
     * We considered making this harder to manipulate, but we decided that if someone were able to
     * pull it off and make their own custom nugg, that would be really fucking cool.
     */
    function currentSeed() public view override returns (bytes32 res) {
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
        else if (currentEpochId() == id) return currentSeed();
        else require(false, 'SEED:GET:0');
    }

    /**
     * @dev
     * @return
     */
    function getSeedWithOffset(uint256 id, uint256 offset) public view override returns (bytes32 res) {
        res = getSeed(id + offset);
    }

    function seedExists(uint256 id) public view override returns (bool res) {
        return _seeds[id] != 0;
    }

    /**
     * @dev
     * @return
     */
    function setSeed() internal {
        require(!seedExists(currentEpochId()), 'SEED:SET:0');
        _seeds[currentEpochId()] = currentSeed();
    }

    /**
     * @dev
     * @return
     */

    /**
     * @dev public wrapper for internal _genesisBlock - to save on gas
     * @inheritdoc IEpochable
     */
    function genesisBlock() public view override returns (uint256 res) {
        res = _state.decodeGenesis();
    }

    /**
     * @dev public wrapper for internal _interval - to save on gas
     * @inheritdoc IEpochable
     */
    function interval() public view override returns (uint256 res) {
        res = _state.decodeInterval();
    }

    function epochFromId(uint48 id) public view returns (EpochMath.Epoch memory res) {
        res = _state.getEpoch(id, block.number);
    }

    /**
     * @dev public wrapper for internal blocknumFirstFromEpoch() - to save on gas
     */
    function epochFromBlocknum(uint256 blocknum) public view override returns (EpochMath.Epoch memory res) {
        res = _state.getEpoch(_state.getIdFromBlocknum(blocknum), block.number);
    }

    /**
     * @dev public wrapper for internal blocknumFirstFromEpoch() - to save on gas
     */
    function epochStatus(uint48 id) public view returns (EpochMath.Status res) {
        return _state.getStatus(id, block.number);
    }

    /**
     * @dev public wrapper for internal blocknumFirstFromEpoch() - to save on gas
     */
    function blocknumFromId(uint48 id) public view returns (uint256) {
        return _state.getStartBlockFromId(id);
    }
}
