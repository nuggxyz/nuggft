// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import {INuggftV1Stake} from "./INuggftV1Stake.sol";
import {INuggftV1Proof} from "./INuggftV1Proof.sol";
import {INuggftV1Swap} from "./INuggftV1Swap.sol";
import {INuggftV1Loan} from "./INuggftV1Loan.sol";
import {INuggftV1Epoch} from "./INuggftV1Epoch.sol";
import {INuggftV1Trust} from "./INuggftV1Trust.sol";
import {INuggftV1ItemSwap} from "./INuggftV1ItemSwap.sol";
import {INuggftV1Globals} from "./INuggftV1Globals.sol";

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
    INuggftV1ItemSwap,
    INuggftV1Globals
{


}

interface INuggftV1Events {
    event Genesis(uint256 blocknum, uint32 interval, uint24 offset, uint8 intervalOffset, uint24 early, address dotnugg, address xnuggftv1, bytes32 stake);
    event OfferItem(uint24 indexed sellingTokenId, uint16 indexed itemId, bytes32 agency, bytes32 stake);
    event ClaimItem(uint24 indexed sellingTokenId, uint16 indexed itemId, uint24 indexed buyerTokenId, bytes32 proof);
    event SellItem(uint24 indexed sellingTokenId, uint16 indexed itemId, bytes32 agency, bytes32 proof);
    event Loan(uint24 indexed tokenId, bytes32 agency);
    event Rebalance(uint24 indexed tokenId, bytes32 agency);
    event Liquidate(uint24 indexed tokenId, bytes32 agency);
    event MigrateV1Accepted(address v1, uint24 tokenId, bytes32 proof, address owner, uint96 eth);
    event Extract(uint96 eth);
    event MigratorV1Updated(address migrator);
    event MigrateV1Sent(address v2, uint24 tokenId, bytes32 proof, address owner, uint96 eth);
    event Burn(uint24 tokenId, address owner, uint96 ethOwed);
    event Stake(bytes32 stake);
    event Rotate(uint24 indexed tokenId, bytes32 proof);
    event Mint(uint24 indexed tokenId, uint96 value, bytes32 proof, bytes32 stake, bytes32 agency);
    event Offer(uint24 indexed tokenId, bytes32 agency, bytes32 stake);
    event OfferMint(uint24 indexed tokenId, bytes32 agency, bytes32 proof, bytes32 stake);
    event Claim(uint24 indexed tokenId, address indexed account);
    event Sell(uint24 indexed tokenId, bytes32 agency);
    event TrustUpdated(address indexed user, bool trust);
}
