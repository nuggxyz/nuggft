// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './core/Stakeable.sol';

import './interfaces/IxNUGG.sol';
import './erc20/ERC20.sol';
import './erc2981/ERC2981Receiver.sol';

/**
 * @title xNUGG
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice leggo
 */
contract xNUGG is IxNUGG, ERC20, Stakeable {
    using Address for address payable;

    address payable public tummy;

    constructor() ERC20('Staked NUGG', 'xNUGG') {
        tummy = payable(msg_sender());
    }

    receive() external payable {
        _recieve();
    }

    fallback() external payable {
        _recieve();
    }

    function _recieve() internal {
        if (msg_value() > 0) {
            uint256 t = (msg_value() * 100) / 1000;
            Stakeable._onValueAdd(msg_sender(), msg_value() - t);
            tummy.sendValue(t);
        }
    }

    function mint() external payable override {
        _mint(msg_sender(), msg_value());
    }

    function burn(uint256 amount) external override {
        _burn(msg_sender(), amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        Stakeable._onShareSub(sender, amount);
        Stakeable._onShareAdd(recipient, amount);
    }

    function _mint(address account, uint256 amount) internal override {
        Stakeable._onShareAdd(account, amount);
    }

    function _burn(address account, uint256 amount) internal override {
        Stakeable._onShareSub(account, amount);
        payable(account).sendValue(amount);
    }

    function totalSupply() public view override(IxNUGG, ERC20, Stakeable) returns (uint256 res) {
        res = Stakeable.totalSupply();
    }

    function totalSupplyMinted() public view override returns (uint256 res) {
        res = ERC20.totalSupply();
    }

    function balanceOfMinted(address from) public view override returns (uint256 res) {
        res = ERC20.balanceOf(from);
    }

    function balanceOf(address from) public view override(IxNUGG, ERC20) returns (uint256 res) {
        res = Stakeable.supplyOf(from);
    }
}
