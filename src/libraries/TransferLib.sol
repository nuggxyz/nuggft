// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

library TransferLib {
    function give(address to, uint256 amount) internal {
        assembly {
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                mstore(0, 0x01)
                revert(0x19, 0x01)
            }
        }
    }
}

//    bool callStatus;

//         assembly {
//             // Transfer the ETH and store if it succeeded or not.
//             callStatus := call(gas(), to, amount, 0, 0, 0, 0)
//         }

//         require(callStatus, 'Z:0');
