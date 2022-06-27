// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {RiggedNuggftV1} from "./RiggedNuggftV1.sol";

import {IDotnuggV1} from "dotnugg-v1-core/IDotnuggV1.sol";

contract RiggedNuggFatherV1 {
    IDotnuggV1 public immutable dotnuggv1;

    RiggedNuggftV1 public immutable nuggftv1;

    constructor() payable {
        nuggftv1 = new RiggedNuggftV1{value: msg.value}();

        dotnuggv1 = IDotnuggV1(address(nuggftv1.dotnuggv1()));
    }
}
