// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/Address.sol';
import './Mutexable.sol';
import '../interfaces/IEscrowable.sol';
import '../erc20/IERC20.sol';
import './Testable.sol';

/**
 * @title Escrowable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice allows withdrawer to have access to funds without any ownership/control over the depositer
 * @dev adapted from Openzeppelin's Escrow.sol
 */
abstract contract Escrowable is IEscrowable, Mutexable {
    Escrow internal immutable _TUMMY;

    constructor() {
        _TUMMY = new Escrow();
    }

    /**
     * @dev returns user's current reward balance
     * @return balance
     */
    function tummy() external view override returns (address) {
        return address(_TUMMY);
    }
}

/**
 * @title Escrow
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice allows withdrawer to have access to funds without any ownership/control over the depositer
 * @dev adapted from Openzeppelin's Escrow.sol
 */
contract Escrow is IEscrow, Mutexable, Testable {
    using Address for address payable;

    address public immutable depositer;

    uint256 private _deposits;

    address public withdrawer;

    constructor() {
        withdrawer = tx.origin;
        depositer = msg_sender();
    }

    /**
     * @inheritdoc IEscrow
     */
    function deposit() external payable override lock(global) {
        address _depositer = depositer;

        require(msg_sender() == _depositer, 'ESC:D:0');

        uint256 amount = msg_value();
        _deposits += amount;
        emit Deposited(_depositer, amount);
    }

    /**
     * @inheritdoc IEscrow
     */
    function withdraw() external override lock(global) {
        address _withdrawer = payable(withdrawer);
        require(msg_sender() == _withdrawer, 'ESC:W:0');
        uint256 payment = _deposits;
        _deposits = 0;
        send_eth(payable(_withdrawer), payment);
        emit Withdrawn(_withdrawer, payment);
    }

    /**
     * @inheritdoc IEscrow
     */
    function rescueERC20(IERC20 token, uint256 amount) external override lock(global) {
        address _withdrawer = payable(withdrawer);

        require(msg_sender() == _withdrawer, 'ESC:RE:0');

        token.transferFrom(address(this), _withdrawer, amount);
    }

    /**
     * @inheritdoc IEscrow
     */
    function deposits() external view override returns (uint256) {
        return _deposits;
    }
}
