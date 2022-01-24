// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import './console.sol';

library gas {
    struct cp {
        string label;
        uint256 left;
    }

    function ptr() private pure returns (cp storage s) {
        assembly {
            s.slot := 0x432343243242342534
        }
    }

    function start(string memory label) internal {
        ptr().label = label;
        ptr().left = gasleft();
    }

    function start() internal {
        ptr().left = gasleft();
    }

    function stop() internal view {
        uint256 checkpointGasLeft2 = gasleft();

        string memory l1 = ptr().label;

        string memory lab = (bytes(l1).length == 0) ? 'no label' : l1;

        console.log(lab, ptr().left - checkpointGasLeft2);
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

        console.log('gas used: ', a);
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

        console.log(mem, a);
    }
}
