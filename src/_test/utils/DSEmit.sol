// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

library DSEmit {
    event log(string);
    event logs(bytes);

    event log_address(address);
    event log_bytes32(bytes32);
    event log_int(int256);
    event log_uint(uint256);
    event log_bytes(bytes);
    event log_string(string);

    event log_named_address(string key, address val);
    event log_named_bytes32(string key, bytes32 val);
    event log_named_decimal_int(string key, int256 val, uint256 decimals);
    event log_named_decimal_uint(string key, uint256 val, uint256 decimals);
    event log_named_int(string key, int256 val);
    event log_named_uint(string key, uint256 val);
    event log_named_bytes(string key, bytes val);
    event log_named_string(string key, string val);

    struct cp {
        string label;
        uint256 left;
    }

    function ptr() private pure returns (cp storage s) {
        assembly {
            s.slot := 0x432343243242342534
        }
    }

    function startMeasuringGas(string memory label) internal {
        ptr().label = label;
        ptr().left = gasleft();
    }

    function stopMeasuringGas() internal {
        uint256 checkpointGasLeft2 = gasleft();

        emit log_named_uint(ptr().label, ptr().left - checkpointGasLeft2);
    }
}
