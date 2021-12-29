// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ForgeVm} from './Vm.sol';

library UserTarget {
    function shouldPass(
        address target,
        User user,
        bytes memory args
    ) internal {
        shouldPass(target, user, args, 0);
    }

    function shouldPass(
        address target,
        User user,
        bytes memory args,
        uint96 eth
    ) internal {
        user.call(target, args, eth);
    }

    function shouldFail(
        address target,
        string memory message,
        User user,
        bytes memory args
    ) internal {
        shouldFail(target, message, user, args, 0);
    }

    function shouldFail(
        address target,
        string memory message,
        User user,
        bytes memory args,
        uint96 eth
    ) internal {
        user.revertCall(target, message, args, eth);
    }
}

contract User {
    ForgeVm internal constant fvm = ForgeVm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    event log_named_string(string key, string val);

    fallback() external payable {}

    receive() external payable {}

    constructor() payable {}

    function tryCall(address target, bytes memory data) public payable virtual returns (bool success, bytes memory returnData) {
        (success, returnData) = target.call{value: msg.value}(data);
    }

    function call(
        address target,
        bytes memory data,
        uint256 eth
    ) public payable virtual returns (bytes memory returnData) {
        bool success;
        (success, returnData) = target.call{value: eth}(data);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let returnDataSize := mload(returnData)
                    revert(add(32, returnData), returnDataSize)
                }
            } else {
                revert('REVERTED_WITHOUT_MESSAGE');
            }
        }
    }

    function revertCall(
        address target,
        string memory message,
        bytes memory data,
        uint256 eth
    ) public payable virtual {
        (bool callSuccess, bytes memory returnData) = target.call{value: eth}(data);

        require(!callSuccess, 'REVERT-CALL SUCCEEDED');

        string memory revertReason = string(extractRevertReason(returnData));

        if (!compareStrings(revertReason, message)) {
            revert(string(abi.encodePacked('UNEXPECTED REVERT: ', revertReason, ' EXPECTED: ', message)));
        }
    }

    function extractRevertReason(bytes memory revertData) internal pure returns (string memory reason) {
        uint256 l = revertData.length;
        if (l < 68) return '';
        uint256 t;
        assembly {
            revertData := add(revertData, 4)
            t := mload(revertData) // Save the content of the length slot
            mstore(revertData, sub(l, 4)) // Set proper length
        }
        reason = abi.decode(revertData, (string));
        assembly {
            mstore(revertData, t) // Restore the content of the length slot
        }
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
