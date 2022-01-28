// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

library lib {
    struct txdata {
        address from;
        uint96 value;
    }

    function addressOf(address addr, uint8 nonce) internal pure returns (address res) {
        assembly {
            mstore(mload(0x40), shl(72, or(shl(176, 0xd6), or(shl(168, 0x94), or(shl(8, addr), nonce)))))
            res := keccak256(addr, 23)
            mstore(mload(0x40), 0x00)
        }
    }

    function sarr(uint256 a) internal pure returns (uint256[] memory array) {
        array = new uint256[](1);
        array[0] = a;
    }

    function sarr160(uint160 a) internal pure returns (uint160[] memory array) {
        array = new uint160[](1);
        array[0] = a;
    }

    function m160(uint160 a, uint16 amount) internal pure returns (uint160[] memory array) {
        array = new uint160[](amount);

        for (uint256 i = 0; i < amount; i++) {
            array[i] = a;
        }
    }

    function sarr176(uint176 a) internal pure returns (uint176[] memory array) {
        array = new uint176[](1);

        array[0] = a;
    }

    function sarr16(uint16 a) internal pure returns (uint16[] memory array) {
        array = new uint16[](1);
        array[0] = a;
    }

    function m16(uint16 a, uint16 amount) internal pure returns (uint16[] memory array) {
        array = new uint16[](amount);

        for (uint256 i = 0; i < amount; i++) {
            array[i] = a;
        }
    }

    function sarrAddress(address a) internal pure returns (address[] memory array) {
        array = new address[](1);
        array[0] = a;
    }

    function mAddress(address a, uint16 amount) internal pure returns (address[] memory array) {
        array = new address[](amount);

        for (uint256 i = 0; i < amount; i++) {
            array[i] = a;
        }
    }

    function take(int256 percent, int256 value) internal pure returns (int256) {
        return (value * percent) / 100;
    }
}
