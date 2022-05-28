// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "./ds.sol";

library gas {
    struct run {
        string label;
        uint256 left;
    }

    function ptr() private pure returns (run storage s) {
        assembly {
            s.slot := 0x432343243242342534
        }
    }

    function start(string memory label) internal view returns (run memory a) {
        // ptr().runs[label] = 0x01;
        // ptr().runs[label] = gasleft();

        a.label = label;
        a.left = gasleft();

        // ptr().left = gasleft();
    }

    // function start() internal {
    //     ptr().left = gasleft();
    // }

    function stop(run memory b) internal view {
        uint256 checkpointGasLeft2 = gasleft();

        ds.inject.log(b.label, b.left - checkpointGasLeft2);
    }
}

contract GasTracker {
    modifier trackGas() {
        uint256 a;
        assembly {
            a := gas()
        }

        _;
        assembly {
            a := sub(a, gas())
        }

        ds.inject.log("gas used: ", a);
    }

    modifier trackGas2(string memory mem) {
        uint256 a;
        assembly {
            a := gas()
        }

        _;
        assembly {
            a := sub(a, gas())
        }

        ds.inject.log(mem, a);
    }
}
