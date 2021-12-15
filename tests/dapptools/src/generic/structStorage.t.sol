// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

import '../../lib/DSTest.sol';

contract structGasTest is DSTest {
    struct Uint256 {
        uint256 u;
    }

    uint256 variable = 4000;
    Uint256 str = Uint256(4000);

    /*///////////////////////////////////////////////////////////////
                                  STORAGE
    //////////////////////////////////////////////////////////////*/
    // winner
    function test_writeUint256fromStorage() public {
        variable += 10000;
    }

    function test_writeStructfromStorage() public {
        str.u += 10000;
    }

    // winner
    function test_readUint256fromStorage() public view {
        variable;
    }

    function test_readStructfromStorage() public view {
        str.u;
    }

    /*///////////////////////////////////////////////////////////////
                                  MEMORY
    //////////////////////////////////////////////////////////////*/

    function test_uint256fromMemorySet() public {
        uint256 v = variable;
        variable = addToValue(v);
    }

    function test_structfromMemoryRef() public {
        Uint256 memory v = str;
        addToValueMemRef(v);
    }

    function test_structfromMemory() public {
        Uint256 memory v = str;
        v.u = addToValueMem(v);
    }

    function test_uint256fromMemory() public {
        uint256 v = variable;
        v = addToValue(v);
    }

    function test_structfromStorageRef() public {
        addToValueMemRef(str);
    }

    // winner
    function addToValue(uint256 input) internal view returns (uint256 res) {
        res = input + 1000;
    }

    function addToValueMemRef(Uint256 memory input) internal view {
        input.u += 1000;
    }

    function addToValueStorageRef(Uint256 storage input) internal {
        input.u += 1000;
    }

    function addToValueMem(Uint256 memory input) internal view returns (uint256 res) {
        res = input.u + 1000;
    }
}
