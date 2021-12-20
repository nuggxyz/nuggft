// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC721Metadata, IERC165} from './IERC721.sol';

import {IdotnuggV1Implementer} from '../interfaces/IdotnuggV1.sol';

interface ITrustExternal {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event TrustUpdated(address indexed user);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/
    function trustedMint(uint160 tokenId, address to) external;

    function extractProtocolEth() external;

    function storeFiles(uint256[][] calldata data, uint8 feature) external;

    function setIsTrusted(address user) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function trusted() external view returns (address);
}

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

    function totalProtocolEth() external view returns (uint96);

    function totalSupply() external view returns (uint256);

    function totalStakedShares() external view returns (uint64);

    function totalStakedEth() external view returns (uint96);

    function activeEthPerShare() external view returns (uint96);
}

interface IProofExternal {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event SetProof(uint160 tokenId, uint256 proof, uint8[] items);
    event PopItem(uint160 tokenId, uint256 proof, uint16 itemId);
    event PushItem(uint160 tokenId, uint256 proof, uint16 itemId);
    event RotateItem(uint160 tokenId, uint256 proof, uint8 feature);
    event SetAnchorOverrides(uint160 tokenId, uint256 proof, uint8[] xs, uint8[] ys);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function rotateFeature(uint160 tokenId, uint8 feature) external;

    function setOverrides(
        uint160 tokenId,
        uint8[] memory xs,
        uint8[] memory ys
    ) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function proofOf(uint160 tokenId) external view returns (uint256);

    function parsedProofOf(uint160 tokenId)
        external
        view
        returns (
            uint256 proof,
            uint8[] memory defaultIds,
            uint8[] memory extraIds,
            uint8[] memory overxs,
            uint8[] memory overys
        );
}

interface IFileExternal is IERC721Metadata, IdotnuggV1Implementer {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function totalLengths() external view returns (uint8[] memory res);
}

interface ILoanExternal {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event TakeLoan(uint160 tokenId, uint96 principal);
    event Payoff(uint160 tokenId, address account, uint96 payoffAmount);
    event Rebalance(uint160 tokenId, uint96 fee, uint96 earned);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function rebalance(uint160 tokenId) external payable;

    function loan(uint160 tokenId) external;

    function payoff(uint160 tokenId) external payable;
}

interface ITokenExternal is IERC721 {
    function mint(uint160 tokenId) external;

    event TrustedMint(address indexed to, uint160 tokenId);
    event UntrustedMint(address indexed by, uint160 tokenId);
}

interface ISwapExternal {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event DelegateMint(uint256 epoch, address account, uint96 eth);
    event DelegateCommit(uint160 tokenId, address account, uint96 eth);
    event DelegateOffer(uint160 tokenId, address account, uint96 eth);
    event SwapClaim(uint160 tokenId, address account, uint32 epoch);
    event SwapStart(uint160 tokenId, address account, uint96 eth);

    event DelegateCommitItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint96 eth);
    event DelegateOfferItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint96 eth);
    event SwapClaimItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint32 epoch);
    event SwapItemStart(uint160 sellingTokenId, uint16 itemId, uint96 eth);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function delegate(uint160 tokenId) external payable;

    function delegateItem(
        uint160 sellerTokenId,
        uint16 itemid,
        uint160 buyerTokenId
    ) external payable;

    function claim(uint160 tokenId) external;

    function claimItem(
        uint160 sellerTokenId,
        uint16 itemid,
        uint160 buyerTokenId
    ) external;

    function swap(uint160 tokenId, uint96 floor) external;

    function swapItem(
        uint160 tokenId,
        uint16 itemid,
        uint96 floor
    ) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function getOfferByAccount(uint160 tokenId, address account) external view returns (uint96 eth);

    function getActiveSwap(uint160 tokenId)
        external
        view
        returns (
            address leader,
            uint96 eth,
            uint32 _epoch,
            bool isOwner
        );
}

interface IEpochExternal {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function epoch() external view returns (uint32 res);
}

interface INuggFT is
    ISwapExternal,
    ITokenExternal,
    IStakeExternal,
    ILoanExternal,
    IProofExternal,
    IFileExternal,
    IEpochExternal,
    ITrustExternal
{
    event Genesis();
}
