// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTest.sol';
import '../../../contracts/interfaces/IDotNugg.sol';
import '../../../contracts/logic/Matrix.sol';

contract AnchorTest is DSTest {
    function test_combine(IDotNugg.Collection memory collection, bytes[] memory inputs) internal pure returns (IDotNugg.Matrix memory resa) {}

    function test_postionForCanvas(IDotNugg.Canvas memory canvas, IDotNugg.Mix memory mix) internal pure {}

    function test_formatForCanvas(IDotNugg.Canvas memory canvas, IDotNugg.Mix memory mix) internal pure {}

    function test_pickVersionIndex(IDotNugg.Canvas memory canvas, IDotNugg.Item memory item) internal pure returns (uint8) {}

    function test_checkRluds(IDotNugg.Rlud memory r1, IDotNugg.Rlud memory r2) internal pure returns (bool) {}

    function test_setMix(
        IDotNugg.Mix memory res,
        IDotNugg.Item memory item,
        uint8 versionIndex
    ) internal pure {}

    function test_updateReceivers(IDotNugg.Canvas memory canvas, IDotNugg.Mix memory mix) internal pure {}

    function test_mergeToCanvas(IDotNugg.Canvas memory canvas, IDotNugg.Mix memory mix) internal pure {}

    function test_calculateReceivers(IDotNugg.Mix memory mix) internal pure {}
}
