// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC721Metadata, IERC165} from './IERC721.sol';

import {IdotnuggV1Implementer} from '../interfaces/IdotnuggV1.sol';

interface ITrustExternal {
    event TrustUpdated(address indexed user);

    function extractProtocolEth() external;

    function storeFiles(uint256[][] calldata data, uint8 feature) external;

    function setIsTrusted(address user) external;

    function trusted() external view returns (address);
}

interface IStakeExternal {
    event StakeEth(uint96 amount);
    event UnStakeEth(uint96 amount);
    event ProtocolEthExtracted(uint96 amount);
    event MigratorV1Updated(address migrator);
    event MigrateV1Sent(address v2, uint160 tokenId, uint256 proof, address owner, uint96 eth);

    function migrateStake(uint160 tokenId) external;

    function withdrawStake(uint160 tokenId) external;

    function totalProtocolEth() external view returns (uint96);

    function totalSupply() external view returns (uint256);

    function totalStakedShares() external view returns (uint64);

    function totalStakedEth() external view returns (uint96);

    function activeEthPerShare() external view returns (uint96);
}

interface IProofExternal {
    event PreMint(uint160 tokenId, uint256[] items);

    event PopItem(uint160 tokenId, uint16 itemId);

    event PushItem(uint160 tokenId, uint16 itemId);

    event SetProof(uint160 tokenId, uint256[] items);

    function rotateFeature(uint160 tokenId, uint8 feature) external;

    function setOverrides(
        uint160 tokenId,
        uint8[] memory xs,
        uint8[] memory ys
    ) external;

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

interface IFileExternal is IdotnuggV1Implementer {}

interface ILoanExternal {
    event TakeLoan(uint160 tokenId, address account, uint96);
    event Payoff(uint160 tokenId, address account, uint96);

    function rebalance(uint160 tokenId) external payable;

    function loan(uint160 tokenId) external;

    function payoff(uint160 tokenId) external payable;
}

interface ITokenExternal is IERC721, IERC721Metadata {}

interface ISwapExternal {
    event Mint(uint160 tokenId, address account, uint96);

    event Commit(uint160 tokenId, address account, uint96);

    event Offer(uint160 tokenId, address account, uint96);

    event Claim(uint160 tokenId, address account);

    event StartSwap(uint160 tokenId, address account, uint96 floor);

    event CommitItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint96 eth);

    event OfferItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint96 eth);

    event ClaimItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId);

    event SwapItem(uint160 sellingTokenId, uint16 itemId, uint96 floor);

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
    function epoch() external view returns (uint32 res);
}

interface INuggFT is ISwapExternal, ITokenExternal, IStakeExternal, ILoanExternal, IProofExternal, IEpochExternal, ITrustExternal {
    event Genesis();
}
