// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTest} from '../../../lib/ds-test/src/test.sol';

import {Hevm, ForgeVm} from './Vm.sol';

contract DSTestPlus is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    //    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    ForgeVm internal constant fvm = ForgeVm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address internal constant DEAD_ADDRESS = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;

    bytes32 checkpointLabel;
    uint256 private checkpointGasLeft;

    function startMeasuringGas(bytes32 label) internal virtual {
        checkpointLabel = label;
        checkpointGasLeft = gasleft();
    }

    function stopMeasuringGas() internal virtual {
        uint256 checkpointGasLeft2 = gasleft();

        bytes32 label = checkpointLabel;

        emit log_named_uint(string(abi.encodePacked(label, ' Gas')), checkpointGasLeft - checkpointGasLeft2 - 22134);
    }

    function fail(bytes32 err) internal virtual {
        emit log_named_string('Error', string(abi.encodePacked(err)));
        fail();
    }

    function assertFalse(bool data) internal virtual {
        assertTrue(!data);
    }

    function assertUint128Eq(uint128 a, uint128 b) internal virtual {
        assertEq(uint256(a), uint256(b));
    }

    function assertUint64Eq(uint64 a, uint64 b) internal virtual {
        assertEq(uint256(a), uint256(b));
    }

    function assertUint96Eq(uint96 a, uint96 b) internal virtual {
        assertEq(uint256(a), uint256(b));
    }

    function assertUint32Eq(uint32 a, uint32 b) internal virtual {
        assertEq(uint256(a), uint256(b));
    }

    function assertBytesEq(bytes memory a, bytes memory b) internal virtual {
        if (keccak256(a) != keccak256(b)) {
            emit log('Error: a == b not satisfied [bytes]');
            emit log_named_bytes('  Expected', b);
            emit log_named_bytes('    Actual', a);
            fail();
        }
    }
}

contract DSInvariantTest {
    address[] private targets;

    function targetContracts() public view virtual returns (address[] memory) {
        require(targets.length > 0, 'NO_TARGET_CONTRACTS');

        return targets;
    }

    function addTargetContract(address newTargetContract) internal virtual {
        targets.push(newTargetContract);
    }
}
