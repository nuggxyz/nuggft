// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './interfaces/INuggETH.sol';
import './interfaces/INuggETHRelay.sol';
import '../base/Mutexable.sol';
import '../base/Launchable.sol';
import '../../node_modules/hardhat/console.sol';

/**
 * @title Testable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice commonly used and current exec context functions that sometimes require simple overriding in testing
 */
contract NuggETHRelay is INuggETHRelay, Mutexable, Launchable {
    INuggETH private _NUGGETH;
    IWETH9 private _WETH;

    constructor() {}

    receive() external payable {
        if (msg_sender() != address(_WETH)) depositETH();
    }

    fallback() external payable {
        if (msg_sender() != address(_WETH)) depositETH();
    }

    function launch(bytes memory data) public override {
        super.launch(data);
        (address nuggeth, address weth) = abi.decode(data, (address, address));
        _NUGGETH = INuggETH(nuggeth);
        _WETH = IWETH9(weth);
    }

    function depositETH() public payable override lock(global) {
        _depositETH(msg_sender(), msg_value());
    }

    function rescueETH() public override lock(global) {
        _depositETH(address(this), address(this).balance);
        require(true, 'D');
    }

    function depositWETH(uint256 amount) public override lock(global) {
        require(_WETH.allowance(msg_sender(), address(this)) >= amount, 'NER:DW:0');
        _WETH.transferFrom(msg_sender(), address(this), amount);
        _WETH.withdraw(amount);
        _depositETH(msg_sender(), amount);
    }

    function rescueWETH() public override lock(global) {
        uint256 amount = _WETH.balanceOf(address(this));
        _WETH.withdraw(amount);
        _depositETH(address(this), amount);
    }

    function rescueERC20(IERC20 token, uint256 amount) public override lock(global) {
        token.approve(_NUGGETH.tummy(), amount);
    }

    function _depositETH(address account, uint256 amount) internal {
        _NUGGETH.depositRewards{value: amount}(account);
    }

    // @todo neeed to have catch for erc20 and other shit
}
