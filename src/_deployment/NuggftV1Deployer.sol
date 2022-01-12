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
        nuggft = new NuggftV1{salt: salt}(trusted, dotnugg);

        nuggft.dotnuggV1StorageProxy().unsafeBulkStore(nuggs);

        for (uint160 i = 1; i < 200; i++) {
            nuggft.trustedMint(i, trusted[0]);
        }

        nuggft.setIsTrusted(address(this), false);
    }
}
