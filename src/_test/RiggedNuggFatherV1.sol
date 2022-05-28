// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import {RiggedNuggftV1} from "./RiggedNuggftV1.sol";

import {DotnuggV1} from "../../../dotnugg-v1-core/src/DotnuggV1.sol";

contract RiggedNuggFatherV1 {
    DotnuggV1 public immutable dotnuggv1;

    RiggedNuggftV1 public immutable nuggftv1;

    constructor() payable {
        nuggftv1 = new RiggedNuggftV1{value: msg.value}();

        dotnuggv1 = DotnuggV1(address(nuggftv1.dotnuggv1()));
    }
}
