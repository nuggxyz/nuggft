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
    using EpochMath for EpochMath.State;

    EpochMath.State private _state;

    constructor(uint16 interval_) {
        require(interval_ <= 255, 'interval too long to always find valid blockhash');
        _state = EpochMath.State({genesisBlock: block.number, interval: uint8(interval_)});
    }

    /**
     * @dev public wrapper for internal _genesisBlock - to save on gas
     * @inheritdoc IEpochable
     */
    function genesisBlock() public view override returns (uint256) {
        return _state.genesisBlock;
    }

    /**
     * @dev public wrapper for internal _interval - to save on gas
     * @inheritdoc IEpochable
     */
    function interval() public view override returns (uint256) {
        return _state.interval;
    }

    /**
     * @dev public wrapper for internal _currentEpoch() - to save on gas
     * @inheritdoc IEpochable
     */
    function currentEpochId() public view override returns (uint256 res) {
        res = EpochMath.getIdFromBlocknum(_state, block.number);
    }

    // /**
    //  * @dev public wrapper for internal blocknumFirstFromEpoch() - to save on gas
    //  */
    // function currentEpoch() public view override returns (EpochMath.Epoch memory res) {
    //     res = epochFromId(currentEpochId());
    // }

    function epochFromId(uint256 id) public view returns (EpochMath.Epoch memory res) {
        res = EpochMath.getEpoch(_state, id, block.number);
    }

    /**
     * @dev public wrapper for internal blocknumFirstFromEpoch() - to save on gas
     */
    function epochFromBlocknum(uint256 blocknum) public view override returns (EpochMath.Epoch memory res) {
        res = epochFromId(EpochMath.getIdFromBlocknum(_state, blocknum));
    }

    /**
     * @dev public wrapper for internal blocknumFirstFromEpoch() - to save on gas
     */
    function epochStatus(uint256 id) public view returns (EpochMath.Status res) {
        return EpochMath.getStatus(_state, id, block.number);
    }

    /**
     * @dev public wrapper for internal blocknumFirstFromEpoch() - to save on gas
     */
    function blocknumFromId(uint256 id) public view returns (uint256) {
        return EpochMath.getStartBlockFromId(_state, id);
    }
}
