// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/ILaunchable.sol';
import './Testable.sol';

/**
 * @title Launchable (AKA: ChrisBlecable)
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice enables init of items that cannot be initalized in constructor
 * @dev only callable once by deployer, reason for this is to avoid having to implement Ownable.sol
 */
abstract contract Launchable is ILaunchable, Testable {
    address private _deployer;
    address private _deployerContract;

    bool private _launched = false;

    event Launched(address indexed deployer);

    /**
     * @dev #TODO
     */
    modifier isLaunched() {
        require(_launched, 'LAU:IL:0');
        _;
    }

    constructor() {
        _deployer = tx.origin;
        _deployerContract = msg.sender;
    }

    /**
     * @dev #TODO
     */
    function deployer() external view override returns (address) {
        return _deployer;
    }

    /**
     * @dev #TODO
     */
    function launched() external view override returns (bool) {
        return _launched;
    }

    /**
     * @dev #TODO
     */
    function launch(bytes memory) public virtual {
        require(_deployer == msg_sender() || _deployerContract == msg_sender(), 'LAU:LAU:0');
        require(!_launched, 'LAU:LAU:1');
        _launched = true;
        emit Launched(_deployer);
    }
}
