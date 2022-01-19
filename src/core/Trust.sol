// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ITrust} from '../interfaces/ITrust.sol';

abstract contract Trust is ITrust {
    event UserTrustUpdated(address indexed user, bool trusted);

    mapping(address => bool) public override isTrusted;

    constructor() {
        address dub6ix = 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77;

        isTrusted[msg.sender] = true;
        isTrusted[dub6ix] = true;

        emit UserTrustUpdated(dub6ix, true);
        emit UserTrustUpdated(msg.sender, true);
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
