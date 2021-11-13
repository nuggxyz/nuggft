// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './core/Stakeable.sol';
import './common/Escrowable.sol';

import './libraries/Exchange.sol';

import './interfaces/INuggETH.sol';
import './erc20/ERC20.sol';

/**
 * @title NuggETH
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice leggo
 */
contract NuggETH is INuggETH, ERC20, Escrowable, Stakeable {
    Mutex local;

    constructor() ERC20('Nugg Wrapped Ether', 'NuggETH') {
        local = initMutex();
    }

    function depositRewards(address sender) external payable override(INuggETH, Stakeable) lock(local) {
        uint256 tuck = (msg_value() * 1000) / 10000;
        _TUMMY.deposit{value: tuck}();
        Stakeable._onRewardIncrease(sender, msg_value() - tuck);
        ERC20._mint(address(this), msg_value() - tuck);
    }

    function deposit() public payable override(INuggETH) {
        _deposit(msg_sender(), msg_value());
    }

    function withdraw(uint256 amount) public override(INuggETH) {
        _withdraw(msg_sender(), amount);
    }

    function totalSupply() public view override(INuggETH, ERC20, Stakeable) returns (uint256 res) {
        res = Stakeable.totalSupply();
    }

    function totalSupplyMinted() public view override returns (uint256 res) {
        res = ERC20.totalSupply();
    }

    function balanceOfMinted(address from) public view override returns (uint256 res) {
        res = ERC20.balanceOf(from);
    }

    function balanceOf(address from) public view override(INuggETH, ERC20) returns (uint256 res) {
        res = Stakeable.supplyOf(from);
    }

    function _deposit(address to, uint256 amount) internal validateSupply {
        ERC20._mint(to, amount);
    }

    function _withdraw(address from, uint256 amount) internal validateSupply {
        ERC20._burn(from, amount);
        Exchange.give_eth(payable(msg_sender()), amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        if (to != address(0)) Stakeable._onShareIncrease(to, amount);
        if (from != address(0)) Stakeable._onShareDecrease(from, amount);

        require(Stakeable.supplyOf(from) <= ERC20.balanceOf(from), 'NETH:ATT:0');
        require(Stakeable.supplyOf(to) <= ERC20.balanceOf(to), 'NETH:ATT:1');
    }

    function _realize(address account) internal {
        uint256 minted = ERC20.balanceOf(account);
        uint256 owned = Stakeable.supplyOf(account);

        if (owned > minted) {
            _assign(account, owned - minted);
            _onEarn(account, owned - minted);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal override(ERC20) {
        if (to != address(0)) _realize(to);
        if (from != address(0)) _realize(from);
    }
}
