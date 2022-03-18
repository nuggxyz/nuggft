// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "./vm.sol";

library global {
    address constant GLOBAL_ADDRESS_PTR = 0xDDdDddDdDdddDDddDDddDDDDdDdDDdDDdDDDDDDd;

    function set(string memory name, address addr) internal {
        set(name, uint160(addr));
    }

    function set(string memory name, uint256 value) internal {
        forge.vm.store(GLOBAL_ADDRESS_PTR, keccak256(abi.encodePacked(name)), bytes32(value));
    }

    function get(string memory name) internal returns (uint256 a) {
        a = uint256(forge.vm.load(GLOBAL_ADDRESS_PTR, keccak256(abi.encodePacked(name))));
    }

    function getAddress(string memory name) internal returns (address a) {
        a = address(uint160(get(name)));
    }

    function getSafe(string memory name) internal returns (uint256 a) {
        a = get(name);
        require(a != 0, string(abi.encodePacked("ERROR:global:getSafe: ", name, " does not exist")));
    }

    function getAddressSafe(string memory name) internal returns (address a) {
        a = address(uint160(getSafe(name)));
    }
}
