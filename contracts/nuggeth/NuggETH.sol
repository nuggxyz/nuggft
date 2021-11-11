// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../base/Stakeable.sol';
import '../base/Escrowable.sol';
import '../base/Launchable.sol';
import '../base/Fallbackable.sol';

import '../libraries/Exchange.sol';

import './interfaces/INuggETH.sol';
import '../erc20/ERC20.sol';
import './NuggETHRelay.sol';
import './NuggETHRelay.sol';

/**
 * @title NuggETH
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice leggo
 */
contract NuggETH is INuggETH, ERC20, Escrowable, Launchable, Fallbackable, Stakeable {
    using Exchange for IWETH9;
    INuggETHRelay private _RELAY;
    IWETH9 private _WETH;

    Mutex local;

    constructor() ERC20('Nugg Wrapped Ether', 'NuggETH') {
        local = initMutex();
    }

    function launch(bytes memory data) public override(Launchable) {
        super.launch(data);
        (address nuggethrelay, address weth) = abi.decode(data, (address, address));
        _RELAY = INuggETHRelay(nuggethrelay);
        _WETH = IWETH9(weth);
    }

    function depositRewards(address sender) external payable override(INuggETH, Stakeable) lock(local) {
        uint256 tuck = (msg_value() * 1000) / 10000;
        _TUMMY.deposit{value: tuck}();
        Stakeable._onRewardIncrease(sender, msg_value() - tuck);
    }

    function deposit() public payable override(INuggETH) {
        _deposit(msg_sender(), msg_value());
    }

    function withdraw(uint256 amount) public override(INuggETH) {
        _withdraw(msg_sender(), amount);
    }

    function depositTo(address to) public payable override(INuggETH) {
        _deposit(to, msg_value());
    }

    function withdrawFrom(address from, uint256 amount) public override(INuggETH) {
        _withdraw(from, amount);
    }

    function depositWeth(uint256 amount) public override(INuggETH) lock(local) {
        _depositWeth(msg_sender(), amount);
    }

    function withdrawWeth(uint256 amount) public override(INuggETH) lock(local) {
        _withdrawWeth(msg_sender(), amount);
    }

    function depositWethTo(address to, uint256 amount) public override(INuggETH) lock(local) {
        _depositWeth(to, amount);
    }

    function withdrawWethFrom(address account, uint256 amount) public override(INuggETH) lock(local) {
        _withdrawWeth(account, amount);
    }

    function relay() public view override(INuggETH) returns (INuggETHRelay res) {
        res = _RELAY;
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

    function _depositWeth(address to, uint256 amount) internal validateSupply {
        Exchange.take_weth(_WETH, msg_sender(), amount);
        ERC20._mint(to, amount);
    }

    function _withdrawWeth(address from, uint256 amount) internal validateSupply {
        ERC20._burn(from, amount);
        Exchange.give_weth(_WETH, msg_sender(), amount);
    }

    function _fallback() internal override(Fallbackable) {
        deposit();
    }

    function _fallback_ok() internal view override(Fallbackable) returns (bool) {
        return msg_sender() != address(_WETH);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        if (to != address(0)) Stakeable._onShareIncrease(to, amount);
        if (from != address(0)) Stakeable._onShareDecrease(from, amount);
        // console.log('to: ', to, from);
        // console.log('to: ', Stakeable.supplyOf(to), ERC20.balanceOf(to));
        // console.log('fr: ', Stakeable.supplyOf(from), ERC20.balanceOf(from));

        require(Stakeable.supplyOf(from) <= ERC20.balanceOf(from), 'NETH:ATT:0');
        require(Stakeable.supplyOf(to) <= ERC20.balanceOf(to), 'NETH:ATT:1');
    }

    function _realize(address account) internal {
        uint256 minted = ERC20.balanceOf(account);
        uint256 owned = Stakeable.supplyOf(account);

        // console.log('b4: ', account);
        // console.log('b4: ', Stakeable.supplyOf(account), ERC20.balanceOf(account));
        if (owned > minted) {
            _assign(account, owned - minted);
            _onEarn(account, owned - minted);
        }

        // console.log('b4: ', account);
        // console.log('b4: ', Stakeable.supplyOf(account), ERC20.balanceOf(account));
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
