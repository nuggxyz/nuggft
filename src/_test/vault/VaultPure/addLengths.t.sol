// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {VaultPure} from '../../../vault/VaultPure.sol';

import "../../utils/Print.sol";

contract VaultPureTest__addLengths is t {

    function test__VaultPure__addLengths__a() public {
        uint256 res =VaultPure.addLengths(0x38383838380fff, 0x001);
        // Print.log( 123,"res");

        emit log_named_bytes32("res", bytes32(res));

        fail();
    }
}
