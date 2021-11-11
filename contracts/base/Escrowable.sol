// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';

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
contract Escrow is IEscrow, AccessControlEnumerable, Mutexable, Testable {
    using Address for address payable;

    uint256 private _deposits;

    constructor() {
        _setupRole('WITHDRAWER', 0x58C59716840b9f2ef87a92b31C12e55c19aC85fb);
        _setupRole('DEPOSITER', msg.sender);
    }

    /**
     * @inheritdoc IEscrow
     */
    function deposit() external payable override onlyRole('DEPOSITER') lock(global) {
        uint256 amount = msg_value();
        _deposits += amount;
        emit Deposited(msg_sender(), amount);
    }

    /**
     * @inheritdoc IEscrow
     */
    function withdraw() external override onlyRole('WITHDRAWER') lock(global) {
        uint256 payment = _deposits;
        _deposits = 0;
        address payable withdrawer = payable(msg_sender());
        send_eth(withdrawer, payment);
        emit Withdrawn(withdrawer, payment);
    }

    /**
     * @inheritdoc IEscrow
     */
    function rescueERC20(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) external override onlyRole('WITHDRAWER') lock(global) {
        token.transferFrom(from, to, amount);
    }

    /**
     * @inheritdoc IEscrow
     */
    function deposits() external view override returns (uint256) {
        return _deposits;
    }
}
