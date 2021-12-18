// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

/// @notice ULTRA minimal authorization logic for smart contracts.
/// @author Inspired by Trust.sol from Rari-Capital (https://github.com/Rari-Capital/solmate/blob/fab107565a51674f3a3b5bfdaacc67f6179b1a9b/src/auth/Trust.sol)
abstract contract StakeTrust {
    address private _trusted;

    event UserTrustUpdated(address indexed user);

    modifier requiresTrust() {
        require(_trusted == msg.sender, 'UNTRUSTED');

        _;
    }

    constructor() {
        _trusted = msg.sender;

        emit UserTrustUpdated(msg.sender);
    }

    function setIsTrusted(address user) public virtual requiresTrust {
        _trusted = user;

        emit UserTrustUpdated(user);
    }

    function trusted() public view returns (address) {
        return _trusted;
    }
}
