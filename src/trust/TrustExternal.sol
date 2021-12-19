// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ITrustExternal} from '../interfaces/INuggFT.sol';

import {StakeCore} from '../stake/StakeCore.sol';
import {VaultCore} from '../vault/VaultCore.sol';

/// @notice ULTRA minimal authorization logic for smart contracts.
/// @author Inspired by Trust.sol from Rari-Capital (https://github.com/Rari-Capital/solmate/blob/fab107565a51674f3a3b5bfdaacc67f6179b1a9b/src/auth/Trust.sol)
abstract contract TrustExternal is ITrustExternal {
    address private _trusted;

    modifier requiresTrust() {
        require(_trusted == msg.sender, 'UNTRUSTED');

        _;
    }

    constructor() {
        _trusted = msg.sender;

        emit TrustUpdated(msg.sender);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/
    function extractProtocolEth() external override requiresTrust {
        StakeCore.trustedExtractProtocolEth();
    }

    function addToVault(uint256[][] calldata data, uint8 feature) external override requiresTrust {
        VaultCore.trustedSet(feature, data);
    }

    function setIsTrusted(address user) external virtual override requiresTrust {
        _trusted = user;

        emit TrustUpdated(user);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function trusted() public view override returns (address) {
        return _trusted;
    }
}
