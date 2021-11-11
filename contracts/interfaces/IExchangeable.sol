pragma solidity 0.8.4;

/**
 * @title IExchangeable
 * @dev interface for Launchable.sol
 */
interface IExchangeable {
    enum Currency {
        ETH,
        WETH,
        NUGGETH,
        INVALID
    }
}
