pragma solidity 0.8.12;

import '../../NuggftV1.test.sol';

import {TransferLib} from '../../../libraries/TransferLib.sol';

contract logic__TransferLib__give is NuggftV1Test {
    function safe__give__a(address recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function safe__give__b(address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, 'ETH_TRANSFER_FAILED');
    }

    function test__logic__TransferLib__gas__give__a() public trackGas {
        safe__give__a(address(users.charlie), 100);
    }

    function test__logic__TransferLib__gas__give__b() public trackGas {
        safe__give__b(address(users.charlie), 100);
    }

    function test__logic__TransferLib__gas__give() public trackGas {
        TransferLib.give(address(users.charlie), 100);
    }

    function test__logic__TransferLib__gas__give__0() public trackGas {
        TransferLib.give(address(users.charlie), 0);
    }

    function test__logic__TransferLib__gas__give__a__0() public trackGas {
        safe__give__a(address(users.charlie), 0);
    }

    function test__logic__TransferLib__gas__give__b__0() public trackGas {
        safe__give__b(address(users.charlie), 0);
    }

    function test__logic__TransferLib__symbolic__give(uint96 amount) public trackGas {
        forge.vm.deal(address(this), uint256(amount) * 3);

        uint256 preBalanceFrank = users.frank.balance;
        safe__give__a(address(users.frank), amount);
        assertEq(preBalanceFrank + amount, users.frank.balance, 'A');

        uint256 preBalanceCharlie = users.charlie.balance;
        safe__give__b(address(users.charlie), amount);
        assertEq(preBalanceCharlie + amount, users.charlie.balance, 'B');

        uint256 preBalanceDee = users.dee.balance;
        TransferLib.give(address(users.dee), amount);
        assertEq(preBalanceDee + amount, users.dee.balance, 'C');
    }
}
