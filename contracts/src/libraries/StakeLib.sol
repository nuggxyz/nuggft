// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './QuadMath.sol';

/**
 * @title StakeMath
 * @notice a library for performing staking operations
 * @dev #TODO
 */
library StakeLib {
    using QuadMath for uint256;

    struct Storage {
        uint256 shares;
        mapping(address => uint256) owned;
    }

    // function load() internal pure returns (Storage storage s) {
    //     uint256 ptr = StorageLib.pointer('epoch');
    //     assembly {
    //         s.slot := ptr
    //     }
    // }

    function getActiveEth() internal view returns (uint256 res) {
        assembly {
            res := selfbalance()
        }
    }

    function getActiveValue() internal view returns (uint256 res) {
        res = getActiveEth() + 10**20;
    }

    function getActiveEthOf(Storage storage s, address account) internal view returns (uint256 res) {
        res = sharesToSupply(s.owned[account], getActiveEth(), s.shares, false);
    }

    function getActiveSharesOf(Storage storage s, address account) internal view returns (uint256 res) {
        res = s.owned[account];
    }

    function getActiveShares(Storage storage s) internal view returns (uint256 res) {
        res = s.shares;
    }

    /**
     * @notice #TODO
     * @return res shares
     * @dev #TODO
     */
    function getActiveOwnershipOf(Storage storage s, address account) internal view returns (uint256 res) {
        return s.owned[account].mulDiv(0x100000000000000000000000000000000, s.shares);
    }

    function start(Storage storage s, address account) internal returns (uint256 res) {
        uint256 ethBalance = getActiveEth();
        uint256 activeShares = s.shares;

        require(ethBalance == 0);
        require(activeShares == s.shares);

        res = 10**20;

        s.shares = res;
        s.owned[account] = res;
    }

    function add(
        Storage storage s,
        address account,
        uint256 eth
    ) internal returns (uint256 shares) {
        // uint256 eth = msg.value;
        require(eth > 0, 'SL:ADD:0');

        uint256 ethBalance = getActiveValue();
        uint256 activeShares = s.shares;

        if (activeShares == 0) {
            require(ethBalance == eth, 'SL:SA:0');
            shares = eth;
        } else {
            uint256 prev_eth_balance = ethBalance - eth;
            shares = supplyToShares(eth, prev_eth_balance, activeShares, false);
        }

        s.shares += shares;
        s.owned[account] += shares;
    }

    function sub(
        Storage storage s,
        address account,
        uint256 shares
    ) internal returns (uint256 eth) {
        uint256 ethBalance = getActiveValue();
        uint256 activeShares = s.shares;

        // require(shares <= s.owned[account], 'SL:SUB:0');

        eth = sharesToSupply(shares, ethBalance, activeShares, false);

        s.shares -= shares;
        s.owned[account] -= shares;
    }

    function move(
        Storage storage s,
        address from,
        address to,
        uint256 shares
    ) internal {
        // require(shares <= s.owned[from], 'SL:SUB:0');

        s.owned[from] -= shares;
        s.owned[to] += shares;
    }

    function supplyToShares(
        uint256 eth,
        uint256 active_eth_supply,
        uint256 active_shares,
        bool roundup
    ) private pure returns (uint256 res) {
        res = roundup
            ? eth.mulDivRoundingUp(active_shares, active_eth_supply)
            : eth.mulDiv(active_shares, active_eth_supply);
    }

    function sharesToSupply(
        uint256 share_amount,
        uint256 active_eth_supply,
        uint256 active_shares,
        bool roundup
    ) private pure returns (uint256 res) {
        res = roundup
            ? share_amount.mulDivRoundingUp(active_eth_supply, active_shares)
            : share_amount.mulDiv(active_eth_supply, active_shares);
    }
}
