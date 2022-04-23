// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {RiggedNuggftV1} from "./RiggedNuggftV1.sol";

import {DotnuggV1} from "../../../dotnugg-v1-core/src/DotnuggV1.sol";

contract RiggedNuggFatherV1 {
    DotnuggV1 public immutable dotnuggv1;

    RiggedNuggftV1 public immutable nuggftv1;

    constructor() payable {
        dotnuggv1 = new DotnuggV1();

        nuggftv1 = new RiggedNuggftV1{value: msg.value}(address(dotnuggv1));
    }
}
