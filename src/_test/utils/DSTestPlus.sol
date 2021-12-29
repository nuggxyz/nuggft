// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTest} from '../../../lib/ds-test/src/test.sol';

import {Hevm, ForgeVm} from './Vm.sol';

contract DSTestPlus is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

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

    function assertBytesEq(bytes memory a, bytes memory b) internal virtual {
        if (keccak256(a) != keccak256(b)) {
            emit log('Error: a == b not satisfied [bytes]');
            emit log_named_bytes('  Expected', b);
            emit log_named_bytes('    Actual', a);
            fail();
        }
    }

    function safeDeal(address user, uint256 amount) internal {
        if (detectDeal(user, amount)) {
            fvm.deal(user, amount);
            return;
        }

        bool callStatus;
        assembly {
            callStatus := call(gas(), user, amount, 0, 0, 0, 0)
        }
        assert(callStatus);
    }

    function detectDeal(address _to, uint256 _amount) public returns (bool) {
        bool success;
        bytes memory data = abi.encodeWithSelector(fvm.deal.selector, _to, _amount);
        address _fvm = address(fvm);
        assembly {
            success := call(
                gas(), // gas remaining
                _fvm, // destination address
                0, // no ether
                add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data), // input length (loaded from the first 32 bytes in the `data` array)
                0, // output buffer
                0 // output length
            )
        }

        return success;
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
