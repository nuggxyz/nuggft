// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ITrust} from '../interfaces/ITrust.sol';

/// @notice Ultra minimal authorization logic for smart contracts.
/// @author Inspired by Dappsys V2 (https://github.com/dapp-org/dappsys-v2/blob/main/src/auth.sol)
abstract contract Trust is ITrust {
    event UserTrustUpdated(address indexed user, bool trusted);

    mapping(address => bool) public override isTrusted;

    constructor(address[] memory inital) {
        for (uint256 i = 0; i < inital.length; i++) {
            isTrusted[inital[i]] = true;
            emit UserTrustUpdated(inital[i], true);
        }
    }

    function setIsTrusted(address user, bool trusted) public virtual requiresTrust {
        isTrusted[user] = trusted;

        emit UserTrustUpdated(user, trusted);
    }

    modifier requiresTrust() {
        _requiresTrust();
        _;
    }

    function _requiresTrust() internal view {
        require(isTrusted[msg.sender], 'UNTRUSTED');
    }
}
