// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

/// Adapted from Rari-Capital/solmate

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Modified from Gnosis (https://github.com/gnosis/gp-v2-contracts/blob/main/src/contracts/libraries/GPv2SafeERC20.sol)
library SafeTransferLib {
    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                               ETH OPERATIONS
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // cheaper than solmate for
    function safeTransferETH(address to, uint256 amount) internal {
        assembly {
            if iszero(amount) {
                stop()
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
