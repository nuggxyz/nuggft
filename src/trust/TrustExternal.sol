// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ITrustExternal} from '../interfaces/nuggft/ITrustExternal.sol';

import {StakeCore} from '../stake/StakeCore.sol';
import {TokenCore} from '../token/TokenCore.sol';
import {Trust} from './TrustStorage.sol';

import {FileCore} from '../file/FileCore.sol';

abstract contract TrustExternal is ITrustExternal {
    address private _trusted;

    Trust.Storage private _trust;

    modifier requiresTrust() {
        require(_trusted == msg.sender, 'UNTRUSTED');
        _trust._isTrusted = true;
        _;
        _trust._isTrusted = false;
    }

    constructor() {
        _trusted = msg.sender;

        emit TrustUpdated(msg.sender);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/
    function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {
        TokenCore.trustedMint(_trust, to, tokenId);
    }

    function extractProtocolEth() external override requiresTrust {
        StakeCore.trustedExtractProtocolEth(_trust);
    }

    function setMigrator(address addr) external requiresTrust {
        StakeCore.trustedSetMigrator(_trust, addr);
    }

    function storeFiles(uint256[][] calldata data, uint8 feature) external override requiresTrust {
        FileCore.trustedStoreFiles(_trust, feature, data);
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
