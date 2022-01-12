// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggftV1} from '../NuggftV1.sol';
import {DotnuggV1} from '../../../dotnugg-core/src/DotnuggV1.sol';
import {IDotnuggV1} from '../../../dotnugg-core/src/interfaces/IDotnuggV1.sol';

contract PureDeployerCallback {
    IDotnuggV1 public dotnuggV1;

    constructor(IDotnuggV1 _dotnugg) {
        dotnuggV1 = _dotnugg;
    }
}

contract PureDeployer {
    NuggftV1 public nuggft;
    DotnuggV1 public dotnugg;

    constructor(
        bytes32 nuggftSalt,
        bytes32 dotnuggSalt,
        uint256[][][] memory nuggs
    ) {
        dotnugg = new DotnuggV1{salt: dotnuggSalt}(); // nonce 1

        new PureDeployerCallback(dotnugg); // nonce 2

        address[] memory input = new address[](1);

        nuggft = new NuggftV1{salt: nuggftSalt}(input); // nonce 3

        nuggft.dotnuggV1StorageProxy().unsafeBulkStore(nuggs);
    }
}
