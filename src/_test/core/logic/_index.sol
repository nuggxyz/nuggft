// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "./logic__CastLib.t.sol";
import "./logic__NuggftV1Epoch.t.sol";
import "./logic__NuggftV1Loan.t.sol";
import "./logic__NuggftV1Proof.t.sol";
import "./logic__NuggftV1Stake.t.sol";
import "./logic__ShiftLib.t.sol";
import "./logic__TransferLib.t.sol";
import "./logic__DotnuggV1Lib.t.sol";
import "./logic__Rarity.t.sol";
import "./logic__Add.t.sol";

contract Logic is
    logic__ShiftLib,
    logic__TransferLib,
    logic__NuggftV1Stake,
    logic__NuggftV1Loan,
    logic__NuggftV1Proof,
    logic__NuggftV1Epoch,
    logic__CastLib,
    logic__DotnuggV1Lib,
    logic__Rarity,
    logic__Add
{
    function setUp() public {
        reset();
    }
}
