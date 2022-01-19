// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

library TransferLib {
    function sendEth(address to, uint256 amount) internal {
        assembly {
            if iszero(amount) {
                return(amount, amount)
            }

            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                mstore(0, 0x69)
                revert(31, 1)
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
