// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/Address.sol';
import '../libraries/Exchange.sol';
import '../base/Testable.sol';
import '../base/Fallbackable.sol';

import '../interfaces/IWETH9.sol';
import '../interfaces/IExchangeable.sol';

/**
 * @title Testable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice commonly used and current exec context functions that sometimes require simple overriding in testing
 */
abstract contract Exchangeable is Testable, IExchangeable, Fallbackable {
    function WETH() internal virtual returns (IWETH9);

    function NUGGETH() internal virtual returns (INuggETH);

    function _fallback() internal virtual override {}

    function _fallback_ok() internal virtual override returns (bool) {
        return msg_sender() != address(WETH()) && msg_sender() != address(NUGGETH());
    }

    // function isWeth(address addr) internal returns (bool) {
    //     return addr == address(WETH()) || addr == address(NUGGETH());
    // }

    // function currencyOf(IWETH9 addr) internal returns (Currency) {
    //     require(isWeth(address(addr)), 'EX:WT:0');
    //     if (addr == NUGGETH()) return Currency.NUGGETH;
    //     return Currency.WETH;
    // }

    // function wethOf(Currency currency) internal returns (IWETH9 res) {
    //     if (currency == Currency.NUGGETH) res = NUGGETH();
    //     else if (currency == Currency.WETH) res = WETH();
    //     else require(false, 'EX:AO:0');
    // }

    function giveCurrency(
        address account,
        uint256 amount,
        Currency currency
    ) internal {
        if (currency == Currency.ETH) Exchange.give_eth(payable(account), amount);
        else if (currency == Currency.WETH) Exchange.give_weth(WETH(), account, amount);
        else if (currency == Currency.NUGGETH) Exchange.give_nuggeth(NUGGETH(), account, amount);
        else require(false, 'EX:GC:0');
    }

    function takeCurrency(
        address account,
        uint256 amount,
        Currency currency
    ) internal {
        if (currency == Currency.ETH) Exchange.take_eth(account, amount);
        else if (currency == Currency.WETH) Exchange.take_weth(WETH(), account, amount);
        else if (currency == Currency.NUGGETH) Exchange.take_nuggeth(NUGGETH(), account, amount);
        else require(false, 'EX:TC:1');
    }
}
