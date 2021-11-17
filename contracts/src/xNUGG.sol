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
            // ERC20._mint(address(this), msg_value() - t);
            tummy.sendValue(t);
        }
    }

    // function onERC2981Received(
    //     address operator,
    //     address from,
    //     address token,
    //     uint256 tokenId,
    //     address erc20,
    //     uint256 amount,
    //     bytes calldata data
    // ) public payable override(ERC2981Receiver, IERC2981Receiver) lock(local) returns (bytes4) {
    //     if (msg_value() > 0) {
    //         uint256 tuck = (msg_value() * 1000) / 10000;
    //         _TUMMY.deposit{value: tuck}();
    //     }

    //     return super.onERC2981Received(operator, from, token, tokenId, erc20, amount, data);
    // }

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

    // function deposit() public payable override(IxNUGG) {
    //     _deposit(msg_sender(), msg_value());
    // }

    // function withdraw(uint256 amount) public override(IxNUGG) {
    //     _withdraw(msg_sender(), amount);
    // }

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

    // function _deposit(address to, uint256 amount) internal validateSupply {
    //     ERC20._mint(to, amount);
    // }

    // function _withdraw(address from, uint256 amount) internal validateSupply {
    //     ERC20._burn(from, amount);
    //     payable(from).sendValue(amount);
    // }

    // function _afterTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) internal override(ERC20) {
    //     if (to != address(0) && to != address(this)) Stakeable._onShareAdd(to, amount);
    //     if (from != address(0) && from != address(this)) Stakeable._onShareSub(from, amount);

    //     require(Stakeable.supplyOf(from) <= ERC20.balanceOf(from), 'NETH:ATT:0');
    //     require(Stakeable.supplyOf(to) <= ERC20.balanceOf(to), 'NETH:ATT:1');
    // }

    // function _realize(address account) internal {
    //     uint256 minted = ERC20.balanceOf(account);
    //     uint256 owned = Stakeable.supplyOf(account);

    //     if (owned > minted) {
    //         _assign(account, owned - minted);
    //         _onRealize(account, owned - minted);
    //     }
    // }

    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint256
    // ) internal override(ERC20) {
    //     if (to != address(0) && to != address(this)) _realize(to);
    //     if (from != address(0) && from != address(this)) _realize(from);
    // }
}
