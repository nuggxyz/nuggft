// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

interface INuggftV1Stake {
    event Extract(uint96 eth);

    event MigratorV1Updated(address migrator);

    event MigrateV1Sent(address v2, uint24 tokenId, bytes32 proof, address owner, uint96 eth);

    event Stake(bytes32 stake);

    function migrate(uint24 tokenId) external;

    // /// @notice burns a nugg from existance, dealing the eth worth of that share to the user
    // /// @dev should only be called directly
    // /// @param tokenId the id of the nugg being burned
    // function burn(uint24 tokenId) external;

    /// @notice returns the total "eps" held by the contract
    /// @dev this value not always equivilent to the "floor" price which can consist of perceived value.
    /// can be looked at as an "intrinsic floor"
    /// @dev this is the value that users will receive when their either burn or loan out nuggs
    /// @return res -> [current staked eth] / [current staked shares]
    function eps() external view returns (uint96);

    /// @notice returns the minimum eth that must be added to create a new share
    /// @dev premium here is used to push against dillution of supply through ensuring the price always increases
    /// @dev used by the front end
    /// @return res -> premium + protcolFee + ethPerShare
    function msp() external view returns (uint96);

    /// @notice returns the amount of eth extractable by protocol
    /// @dev this will be
    /// @return res -> (PROTOCOL_FEE_FRAC * [all eth staked] / 10000) - [all previously extracted eth]
    function proto() external view returns (uint96);

    /// @notice returns the total number of staked shares held by the contract
    /// @dev this is equivilent to the amount of nuggs in existance
    function shares() external view returns (uint64);

    /// @notice same as shares
    /// @dev for external entities like etherscan
    function totalSupply() external view returns (uint256);

    /// @notice returns the total amount of staked eth held by the contract
    /// @dev can be used as the market-cap or tvl of all nuggft v1
    /// @dev not equivilent to the balance of eth the contract holds, which also has protocolEth ...
    /// + unclaimed eth from unsuccessful swaps + eth from current waps
    function staked() external view returns (uint96);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @notice sends the current protocolEth to the user and resets the value to zero
    /// @dev caller must be a trusted user
    function extract() external;

    /// @notice sets the migrator contract
    /// @dev caller must be a trusted user
    /// @param migrator the address to set as the migrator contract
    function setMigrator(address migrator) external;
}
