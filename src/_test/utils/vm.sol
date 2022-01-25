// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

library forge {
    Vm internal constant vm = Vm(address(bytes20(uint160(uint256(keccak256('hevm cheat code'))))));
}

library lib {
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

    function sarrAddress(address a) internal pure returns (address[] memory array) {
        array = new address[](1);
        array[0] = a;
    }
}

interface Vm {
    // Set block.timestamp (newTimestamp)
    function warp(uint256) external;

    // Set block.height (newHeight)
    function roll(uint256) external;

    // Set block.basefee (newBasefee)
    function fee(uint256) external;

    // Loads a storage slot from an address (who, slot)
    function load(address, bytes32) external returns (bytes32);

    // Stores a value to an address' storage slot, (who, slot, value)
    function store(
        address,
        bytes32,
        bytes32
    ) external;

    // Signs data, (privateKey, digest) => (v, r, s)
    function sign(uint256, bytes32)
        external
        returns (
            uint8,
            bytes32,
            bytes32
        );

    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);

    // Performs a foreign function call via terminal, (stringInputs) => (result)
    function ffi(string[] calldata) external returns (bytes memory);

    // Sets the *next* call's msg.sender to be the input address
    function prank(address) external;

    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
    function startPrank(address) external;

    // Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
    function prank(address, address) external;

    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and the tx.origin to be the second input
    function startPrank(address, address) external;

    // Resets subsequent calls' msg.sender to be `address(this)`
    function stopPrank() external;

    // Sets an address' balance, (who, newBalance)
    function deal(address, uint256) external;

    // Sets an address' code, (who, newCode)
    function etch(address, bytes calldata) external;

    // Expects an error on next call
    function expectRevert(bytes calldata) external;

    // Record all storage reads and writes
    function record() external;

    // Gets all accessed reads and write slot from a recording session, for a given address
    function accesses(address) external returns (bytes32[] memory reads, bytes32[] memory writes);

    // Prepare an expected log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData).
    // Call this function, then emit an event, then call a function. Internally after the call, we check if
    // logs were emitted in the expected order with the expected topics and data (as specified by the booleans)
    function expectEmit(
        bool,
        bool,
        bool,
        bool
    ) external;

    // Mocks a call to an address, returning specified data.
    // Calldata can either be strict or a partial match, e.g. if you only
    // pass a Solidity selector to the expected calldata, then the entire Solidity
    // function will be mocked.
    function mockCall(
        address,
        bytes calldata,
        bytes calldata
    ) external;

    // Clears all mocked calls
    function clearMockedCalls() external;

    // Expect a call to an address with the specified calldata.
    // Calldata can either be strict or a partial match
    function expectCall(address, bytes calldata) external;
}
