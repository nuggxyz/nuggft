pragma solidity 0.8.4;

import '../storage/StakeStorage.sol';
import '../libraries/StakeLib.sol';
import '../libraries/QuadMath.sol';

library StakeModule {
    using StakeLib for uint256;
    using QuadMath for uint256;

    // ┌───────────────────────────────────────────────┐
    // │                      _ _  __ _                │
    // │                     | (_)/ _(_)               │
    // │  _ __ ___   ___   __| |_| |_ _  ___ _ __ ___  │
    // │ | '_ ` _ \ / _ \ / _` | |  _| |/ _ \ '__/ __| │
    // │ | | | | | | (_) | (_| | | | | |  __/ |  \__ \ │
    // │ |_| |_| |_|\___/ \__,_|_|_| |_|\___|_|  |___/ │
    // │                                               │
    // └───────────────────────────────────────────────┘

    //           _    _
    //   __ _ __| |__| |
    //  / _` / _` / _` |
    //  \__,_\__,_\__,_|
    //
    /// @notice Explain to an end user what this does @todo
    /// @dev Explain to a developer any extra details @todo
    /// @param eth add description @todo
    /// @param account add description @todo
    /// @return sharesAdded uint256 add description @todo

    function add(address account, uint256 eth) internal returns (uint256 sharesAdded) {
        // uint256 eth = msg.value;
        require(eth > 0, 'SL:ADD:0');

        StakeStorage.Bin storage s = StakeStorage.load();
        uint256 ethBalance = balance();
        uint256 activeShares = s.shares;

        if (activeShares == 0) {
            require(ethBalance == eth, 'SL:SA:0');
            sharesAdded = eth;
        } else {
            uint256 prev_eth_balance = ethBalance - eth;

            sharesAdded = StakeLib.toShares(eth, prev_eth_balance, activeShares, false);
        }

        s.shares += sharesAdded;
        s.owned[account] += sharesAdded;
    }

    //           _
    //   ____  _| |__
    //  (_-< || | '_ \
    //  /__/\_,_|_.__/
    //
    /// @notice Explain to an end user what this does @todo
    /// @dev Explain to a developer any extra details @todo
    /// @param eth add description @todo
    /// @param account add description @todo
    /// @return sharesSubtracted uint256 add description @todo

    function sub(address account, uint256 eth) internal returns (uint256 sharesSubtracted) {
        StakeStorage.Bin storage s = StakeStorage.load();

        uint256 ethBalance = balance();
        uint256 activeShares = s.shares;

        sharesSubtracted = StakeLib.toShares(eth, ethBalance, activeShares, true);

        s.shares -= sharesSubtracted;
        s.owned[account] -= sharesSubtracted;
    }

    //   _ __  _____ _____
    //  | '  \/ _ \ V / -_)
    //  |_|_|_\___/\_/\___|
    //
    /// @notice Explain to an end user what this does @todo
    /// @dev Explain to a developer any extra details @todo
    /// @param from add description @todo
    /// @param to add description @todo
    /// @param eth add description @todo
    /// @return shares uint256 add description @todo

    function move(
        address from,
        address to,
        uint256 eth
    ) internal returns (uint256 shares) {
        StakeStorage.Bin storage s = StakeStorage.load();

        uint256 ethBalance = balance();
        uint256 activeShares = s.shares;

        shares = StakeLib.toShares(eth, ethBalance, activeShares, true);

        s.owned[from] -= shares;
        s.owned[to] += shares;
    }

    // ┌─────────────────────────┐
    // │        _                │
    // │       (_)               │
    // │ __   ___  _____      __ │
    // │ \ \ / / |/ _ \ \ /\ / / │
    // │  \ V /| |  __/\ V  V /  │
    // │   \_/ |_|\___| \_/\_/   │
    // │                         │
    // └─────────────────────────┘

    function balance() internal view returns (uint256 res) {
        assembly {
            res := selfbalance()
        }
    }

    function getActiveBalanceOf(address account) internal view returns (uint256 res) {
        StakeStorage.Bin storage s = StakeStorage.load();
        res = StakeLib.toSupply(s.owned[account], balance(), s.shares, false);
    }

    function getActiveSharesOf(address account) internal view returns (uint256 res) {
        res = StakeStorage.load().owned[account];
    }

    function getActiveShares() internal view returns (uint256 res) {
        res = StakeStorage.load().shares;
    }

    function getActiveOwnershipOf(address account) internal view returns (uint256 res) {
        StakeStorage.Bin storage s = StakeStorage.load();
        return s.owned[account].mulDiv(0x100000000000000000000000000000000, s.shares);
    }
}
