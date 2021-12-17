// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC721Metadata, IERC165} from './IERC721.sol';

interface IStakeExternal {
    event StakeEth(uint256 amount);
    event UnStakeEth(uint256 amount);

    function totalSupply() external view returns (uint256);

    function totalStakedShares() external view returns (uint256);

    function totalStakedEth() external view returns (uint256);

    function activeEthPerShare() external view returns (uint256);
}

interface IProofExternal {
    event PreMint(uint256 tokenId, uint256[] items);

    event PopItem(uint256 tokenId, uint256 itemId);

    event PushItem(uint256 tokenId, uint256 itemId);

    event SetProof(uint256 tokenId, uint256[] items);

    function proofOf(uint256 tokenId) external view returns (uint256);

    function parsedProofOf(uint256 tokenId)
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

    function resolverOf(uint256 tokenId) external view returns (address);
}

interface ILoanExternal {
    event TakeLoan(uint256 tokenId, address account, uint256 eth);
    event Payoff(uint256 tokenId, address account, uint256 eth);

    function payoffAmount() external view returns (uint256);

    function loan(uint256 tokenId) external;

    function payoff(uint256 tokenId) external payable;
}

interface ITokenExternal is IERC721, IERC721Metadata {}

interface ISwapExternal {
    event Mint(uint256 epoch, address account, uint256 eth);

    event Commit(uint256 tokenid, address account, uint256 eth);

    event Offer(uint256 tokenid, address account, uint256 eth);

    event Claim(uint256 tokenid, uint256 endingEpoch, address account);

    event StartSwap(uint256 tokenid, address account, uint256 eth);

    event CommitItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);

    event OfferItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);

    event ClaimItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 endingEpoch);

    event SwapItem(uint256 sellingTokenId, uint256 itemId, uint256 eth);

    function delegate(uint160 tokenid) external payable;

    function delegateItem(
        uint160 sellerTokenId,
        uint16 itemid,
        uint160 buyerTokenId
    ) external payable;

    function claim(uint160 tokenid) external;

    function claimItem(
        uint160 sellerTokenId,
        uint16 itemid,
        uint160 buyerTokenId
    ) external;

    function swap(uint160 tokenid, uint256 floor) external;

    function swapItem(
        uint160 tokenid,
        uint16 itemid,
        uint256 floor
    ) external;

    function getOfferByAccount(uint160 tokenid, address account) external view returns (uint256 eth);

    function getActiveSwap(uint160 tokenid)
        external
        view
        returns (
            address leader,
            uint256 eth,
            uint32 _epoch,
            bool isOwner
        );
}

interface IEpochExternal {
    function epoch() external view returns (uint256 res);
}

interface INuggFT is ISwapExternal, ITokenExternal, IStakeExternal, ILoanExternal, IProofExternal, IVaultExternal, IEpochExternal {
    event Genesis();
}
