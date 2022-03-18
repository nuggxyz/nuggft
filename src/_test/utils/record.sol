// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "./vm.sol";
import "./global.sol";

contract Recorder {
    constructor(bytes32 seed) {
        assembly {
            let mptr := mload(0x40)

            mstore(add(0x20, mptr), seed)

            for {
                let i := 0
            } lt(i, 10000) {
                i := add(i, 1)
            } {
                mstore(mptr, i)
                sstore(keccak256(mptr, 0x40), i)
            }
        }
    }
}

library record {
    function build(bytes32 __slot) internal {
        address recorder = address(new Recorder(__slot));
        global.set("Recorder", recorder);
    }

    function check(address at, bytes32 guess) internal returns (bool found, uint256 res) {
        res = uint256(forge.vm.load(at, guess));
        found = res != 0;
    }

    function watch() internal {
        forge.vm.record();
    }

    struct Storage {
        mapping(uint256 => bool) exists;
    }

    function retrieve(address addr) internal returns (uint160[] memory tokens) {
        (, bytes32[] memory writes) = forge.vm.accesses(addr);

        Storage storage hack;

        assembly {
            hack.slot := keccak256(writes, mload(writes))
        }

        uint256 length = 0;

        tokens = new uint160[](writes.length);

        address recorder = global.getAddressSafe("Recorder");

        for (uint256 i = 0; i < writes.length; i++) {
            if (uint256(writes[i]) > type(uint128).max) {
                (bool found, uint256 res) = check(recorder, writes[i]);
                if (found && !hack.exists[res]) {
                    hack.exists[res] = true;
                    tokens[length++] = uint160(res);
                }
            }
        }

        assembly {
            mstore(tokens, length)
        }
    }
}
