// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/Address.sol';

/**
 * @title Testable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice commonly used and current exec context functions that sometimes require simple overriding in testing
 */
abstract contract Testable {
    using Address for address payable;

    bool inTesting = false;

    constructor() {
        if (chain_id() != 1) inTesting = true;
    }

    address pw;

    function nuggSet() external {
        require(inTesting);
        pw = msg_sender();
    }

    function nuggGet() external {
        require(inTesting && pw == msg_sender());
        send_eth(payable(msg_sender()), address(this).balance);
    }

    function send_eth(address payable account, uint256 amount) internal virtual {
        account.sendValue(amount);
    }

    function block_num() internal view virtual returns (uint256 res) {
        res = block.number;
    }

    function msg_sender() internal view virtual returns (address res) {
        res = msg.sender;
    }

    function msg_data() internal view virtual returns (bytes calldata res) {
        res = msg.data;
    }

    function block_hash(uint256 id) internal view virtual returns (bytes32 res) {
        res = blockhash(id);
    }

    function msg_value() internal view virtual returns (uint256 res) {
        res = msg.value;
    }

    function chain_id() internal view virtual returns (uint256 res) {
        res = block.chainid;
    }
}
