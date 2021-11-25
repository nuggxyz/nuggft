// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './QuadMath.sol';
import './StorageLib.sol';

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

    function load() internal pure returns (Storage storage s) {
        uint256 ptr = StorageLib.pointer('epoch');
        assembly {
            s.slot := ptr
        }
    }

    function getActiveEth() internal view returns (uint256 res) {
        assembly {
            res := selfbalance()
        }
    }

    function getActiveEthOf(address account) internal view returns (uint256 res) {
        Storage storage s = load();
        res = sharesToSupply(s.owned[account], getActiveEth(), s.shares, false);
    }

    function getActiveSharesOf(address account) internal view returns (uint256 res) {
        res = load().owned[account];
    }

    function getActiveShares() internal view returns (uint256 res) {
        res = load().shares;
    }

    /**
     * @notice #TODO
     * @return res shares
     * @dev #TODO
     */
    function getActiveOwnershipOf(address account) internal view returns (uint256 res) {
        Storage storage s = load();
        return s.owned[account].mulDiv(0x100000000000000000000000000000000, s.shares);
    }

    function add(address account, uint256 eth) internal returns (uint256 sharesAdded) {
        // uint256 eth = msg.value;
        require(eth > 0, 'SL:ADD:0');

        Storage storage s = load();

        uint256 ethBalance = getActiveEth();
        uint256 activeShares = s.shares;

        if (activeShares == 0) {
            require(ethBalance == eth, 'SL:SA:0');
            sharesAdded = eth;
        } else {
            uint256 prev_eth_balance = ethBalance - eth;
            sharesAdded = supplyToShares(eth, prev_eth_balance, activeShares, false);
        }

        s.shares += sharesAdded;
        s.owned[account] += sharesAdded;
    }

    function sub(address account, uint256 eth) internal returns (uint256 sharesSubtracted) {
        Storage storage s = load();

        uint256 ethBalance = getActiveEth();
        uint256 activeShares = s.shares;

        sharesSubtracted = supplyToShares(eth, ethBalance, activeShares, true);

        s.shares -= sharesSubtracted;
        s.owned[account] -= sharesSubtracted;
    }

    function move(
        address from,
        address to,
        uint256 eth
    ) internal returns (uint256 shares) {
        Storage storage s = load();

        uint256 ethBalance = getActiveEth();
        uint256 activeShares = s.shares;

        shares = supplyToShares(eth, ethBalance, activeShares, true);

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
