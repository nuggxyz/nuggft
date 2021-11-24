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

    function toShares(
        uint256 eth,
        uint256 active_eth_supply,
        uint256 active_shares,
        bool roundup
    ) internal pure returns (uint256 res) {
        res = roundup
            ? eth.mulDivRoundingUp(active_shares, active_eth_supply)
            : eth.mulDiv(active_shares, active_eth_supply);
    }

    function toSupply(
        uint256 share_amount,
        uint256 active_eth_supply,
        uint256 active_shares,
        bool roundup
    ) internal pure returns (uint256 res) {
        res = roundup
            ? share_amount.mulDivRoundingUp(active_eth_supply, active_shares)
            : share_amount.mulDiv(active_eth_supply, active_shares);
    }
}
