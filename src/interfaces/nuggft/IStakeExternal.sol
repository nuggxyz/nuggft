// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IStakeExternal {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event StakeEth(uint96 stake, uint96 protocol);
    event UnStakeEth(uint96 stake, address to);
    event ProtocolEthExtracted(uint96 eth);
    event MigratorV1Updated(address migrator);
    event MigrateV1Sent(address v2, uint160 tokenId, uint256 proof, address owner, uint96 eth);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function migrateStake(uint160 tokenId) external;

    function withdrawStake(uint160 tokenId) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function verifiedMinSharePrice() external view returns (uint96 res);

    function totalProtocolEth() external view returns (uint96);

    function totalSupply() external view returns (uint256);

    function totalStakedShares() external view returns (uint64);

    function totalStakedEth() external view returns (uint96);

    function activeEthPerShare() external view returns (uint96);
}
