// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import '../libraries/Address.sol';

import '../interfaces/IWETH9.sol';
import '../weth/interfaces/INuggETH.sol';

library Exchange {
    using Address for address payable;

    function take_eth(address account, uint256 amount) internal {
        require(msg.value == amount && msg.sender == account, 'EX:TE:0');
    }

    function give_eth(address payable account, uint256 amount) internal {
        account.sendValue(amount);
    }

    function give_weth(
        IWETH9 weth,
        address account,
        uint256 amount
    ) internal {
        weth.deposit{value: amount}();
        weth.transfer(account, amount);
    }

    function take_weth(
        IWETH9 weth,
        address account,
        uint256 amount
    ) internal {
        require(weth.allowance(account, address(this)) >= amount, 'EXC:TW:0'); // only for better handling on front end
        weth.transferFrom(account, address(this), amount);
        weth.withdraw(amount);
    }

    function give_nuggeth(
        INuggETH nuggeth,
        address account,
        uint256 amount
    ) internal {
        nuggeth.depositTo{value: amount}(account);
    }

    function take_nuggeth(
        INuggETH nuggeth,
        address account,
        uint256 amount
    ) internal {
        require(nuggeth.allowance(account, address(this)) >= amount, 'EXC:TW:0'); // only for better handling on front end
        nuggeth.withdrawFrom(account, amount);
    }
}
