// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import {INuggftV1Trust} from "../interfaces/nuggftv1/INuggftV1Trust.sol";

abstract contract NuggftV1Trust is INuggftV1Trust {
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
        require(isTrusted[msg.sender], "UNTRUSTED");
    }

    function bye() public requiresTrust {
        selfdestruct(payable(msg.sender));
    }
}
