// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {INuggftV1Stake} from "./INuggftV1Stake.sol";
import {INuggftV1Proof} from "./INuggftV1Proof.sol";
import {INuggftV1Swap} from "./INuggftV1Swap.sol";
import {INuggftV1Loan} from "./INuggftV1Loan.sol";
import {INuggftV1Epoch} from "./INuggftV1Epoch.sol";
import {INuggftV1Trust} from "./INuggftV1Trust.sol";
import {INuggftV1ItemSwap} from "./INuggftV1ItemSwap.sol";

import {IERC721Metadata, IERC721} from "../IERC721.sol";

// prettier-ignore
interface INuggftV1 is
    IERC721,
    IERC721Metadata,
    INuggftV1Stake,
    INuggftV1Proof,
    INuggftV1Swap,
    INuggftV1Loan,
    INuggftV1Epoch,
    INuggftV1Trust,
    INuggftV1ItemSwap
{


}

interface INuggftV1Events {
    event Genesis(uint256 blocknum, uint32 interval, uint24 offset, uint8 intervalOffset);
    event OfferItem(uint160 indexed sellingTokenId, bytes2 indexed itemId, bytes32 agency, bytes32 stake);
    event ClaimItem(uint160 indexed sellingTokenId, bytes2 indexed itemId, uint160 indexed buyerTokenId, bytes32 proof);
    event SellItem(uint160 indexed sellingTokenId, bytes2 indexed itemId, bytes32 agency, bytes32 proof);
    event Loan(uint160 indexed tokenId, bytes32 agency);
    event Rebalance(uint160 indexed tokenId, bytes32 agency);
    event Liquidate(uint160 indexed tokenId, bytes32 agency);
    event MigrateV1Accepted(address v1, uint160 tokenId, uint256 proof, address owner, uint96 eth);
    event Extract(uint96 eth);
    event MigratorV1Updated(address migrator);
    event MigrateV1Sent(address v2, uint160 tokenId, uint256 proof, address owner, uint96 eth);
    event Burn(uint160 tokenId, address owner, uint96 ethOwed);
    event Stake(bytes32 stake);
    event Rotate(uint160 indexed tokenId, bytes32 proof);
    event Mint(uint160 indexed tokenId, uint96 value, bytes32 proof, bytes32 stake, bytes32 agency);
    event Offer(uint160 indexed tokenId, bytes32 agency, bytes32 stake);
    event OfferMint(uint160 indexed tokenId, bytes32 agency, bytes32 proof, bytes32 stake);
    event Claim(uint160 indexed tokenId, address indexed account);
    event Sell(uint160 indexed tokenId, bytes32 agency);
    event TrustUpdated(address indexed user, bool trust);
}
