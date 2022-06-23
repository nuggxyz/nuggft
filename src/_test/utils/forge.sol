// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;

import "./DSTest.sol";
import "./logger.sol";
import "./stdlib.sol";
import "./gas.sol";
import "./vm.sol";
import "./cast.sol";
import "./ds.sol";
import "./lib.sol";
import "./global.sol";
import "./record.sol";
import "./array.sol";
import "./strings.sol";
import "./byteslib.sol";

abstract contract ForgeTest is GasTracker, DSTest {
    modifier prank(address user, uint256 value) {
        forge.vm.deal(user, value);
        forge.vm.startPrank(user);
        _;
        forge.vm.stopPrank();
    }

    modifier globalDs() {
        ds.setDsTest(address(this));
        _;
    }

    constructor() {
        ds.setDsTest(address(this));

        users.frank = forge.vm.addr(uint256(keccak256(abi.encode("frank"))));
        users.dee = forge.vm.addr(uint256(keccak256(abi.encode("dee"))));
        users.mac = forge.vm.addr(uint256(keccak256(abi.encode("mac"))));
        users.dennis = forge.vm.addr(uint256(keccak256(abi.encode("dennis"))));
        users.charlie = forge.vm.addr(uint256(keccak256(abi.encode("charlie"))));
        users.safe = forge.vm.addr(uint256(keccak256(abi.encode("safe"))));

        forge.vm.label(users.frank, "frank");
        forge.vm.label(users.dee, "dee");
        forge.vm.label(users.mac, "mac");
        forge.vm.label(users.dennis, "dennis");
        forge.vm.label(users.charlie, "charlie");
        forge.vm.label(users.safe, "safe");
    }

    struct Users {
        address frank;
        address dee;
        address mac;
        address dennis;
        address charlie;
        address safe;
    }

    Users public users;
}
