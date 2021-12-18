// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC721Metadata, IERC165} from './IERC721.sol';

interface IStakeExternal {
    event StakeEth(uint96 amount);
    event UnStakeEth(uint96 amount);

    function extractProtocolEth() external;

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

    function proofOf(uint160 tokenId) external view returns (uint256);

    function parsedProofOf(uint160 tokenId)
        external
        view
        returns (
            uint256 proof,
            uint16[] memory defaultIds,
            uint16[] memory extraIds,
            uint16[] memory overrides
        );
}

interface IVaultExternal {
    function defaultResolver() external view returns (address);

    function resolverOf(uint160 tokenId) external view returns (address);
}

interface ILoanExternal {
    event TakeLoan(uint160 tokenId, address account, uint96);
    event Payoff(uint160 tokenId, address account, uint96);

    function payoffAmount() external view returns (uint256);

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

interface INuggFT is ISwapExternal, ITokenExternal, IStakeExternal, ILoanExternal, IProofExternal, IVaultExternal, IEpochExternal {
    event Genesis();
}
