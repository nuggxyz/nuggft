// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggftV1} from '../NuggftV1.sol';

contract NuggftV1Deployer {
    NuggftV1 public nuggft;

    constructor(
        bytes32 salt,
        address[] memory trusted,
        address dotnugg,
        uint256[][][] memory nuggs
    ) {
        // address[] memory trustedUpdate = new address[](trusted.length + 1);

        // for (uint256 i = 0; i < trusted.length; i++) {
        //     trustedUpdate[i] = trusted[i];
        // }

        // trustedUpdate[trusted.length] = address(this);

        nuggft = new NuggftV1{salt: salt}(trusted);

        nuggft.dotnuggV1StorageProxy().unsafeBulkStore(nuggs);

        nuggft.setIsTrusted(address(this), false);
    }
}
