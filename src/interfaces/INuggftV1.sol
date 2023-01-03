// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import {IDotnuggV1} from "@dotnugg-v1-core/src/IDotnuggV1.sol";
import {IxNuggftV1} from "@nuggft-v1-core/src/interfaces/IxNuggftV1.sol";

import {IERC721, IERC721Metadata} from "@nuggft-v1-core/src/interfaces/IERC721.sol";

interface INuggftV1Lens {
	/* ///////////////////////////////////////////////////////////////////
                            EPOCH
    /////////////////////////////////////////////////////////////////// */

	function epoch() external view returns (uint24 res);

	/* ///////////////////////////////////////////////////////////////////
                            PROOF
    /////////////////////////////////////////////////////////////////// */

	function proofOf(uint24 tokenId) external view returns (uint256 res);

	function tokensOf(address you) external view returns (uint24[] memory res);

	function proofFromSeed(uint256 seed) external view returns (uint256);

	function premintTokens() external view returns (uint24 first, uint24 last);

	function imageSVG(uint256 tokenId) external view returns (string memory);

	function imageURI(uint256 tokenId) external view returns (string memory res);

	function image123(
		uint256 tokenId,
		bool base64,
		uint8 chunk,
		bytes memory prev
	) external view returns (bytes memory res);

	/* ///////////////////////////////////////////////////////////////////
                            STAKE
    /////////////////////////////////////////////////////////////////// */

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

	/* ///////////////////////////////////////////////////////////////////
                            NUGG SWAPS
    /////////////////////////////////////////////////////////////////// */

	/// @notice calculates the minimum eth that must be sent with a offer call
	/// @dev returns 0 if no offer can be made for this oken
	/// @param tokenId -> the token to be offerd to
	/// @param sender -> the address of the user who will be delegating
	/// @return canOffer -> instead of reverting this function will return false
	/// @return nextMinUserOffer -> the minimum value that must be sent with a offer call
	/// @return currentUserOffer ->
	function check(address sender, uint24 tokenId)
		external
		view
		returns (
			bool canOffer,
			uint96 nextMinUserOffer,
			uint96 currentUserOffer,
			uint96 currentLeaderOffer,
			uint96 incrementBps
		);

	function vfo(address sender, uint24 tokenId) external view returns (uint96 res);

	function agencyOf(uint24 tokenId) external view returns (uint256 res);

	/* ///////////////////////////////////////////////////////////////////
                            ITEM SWAPS
    /////////////////////////////////////////////////////////////////// */

	/// @notice calculates the minimum eth that must be sent with a offer call
	/// @dev returns 0 if no offer can be made for this oken
	/// @param buyer -> the token to be offerd to
	/// @param seller -> the address of the user who will be delegating
	/// @param itemId -> the address of the user who will be delegating
	/// @return canOffer -> instead of reverting this function will return false
	/// @return nextMinUserOffer -> the minimum value that must be sent with a offer call
	/// @return currentUserOffer ->
	function check(
		uint24 buyer,
		uint24 seller,
		uint16 itemId
	)
		external
		view
		returns (
			bool canOffer,
			uint96 nextMinUserOffer,
			uint96 currentUserOffer,
			uint96 currentLeaderOffer,
			uint96 incrementBps,
			bool mustClaimBuyer,
			bool mustOfferOnSeller
		);

	function vfo(
		uint24 buyer,
		uint24 seller,
		uint16 itemId
	) external view returns (uint96 res);

	function itemAgencyOf(uint24 seller, uint16 itemId) external view returns (uint256 res);

	/* ///////////////////////////////////////////////////////////////////
                            LOANS
    /////////////////////////////////////////////////////////////////// */

	/// @notice for a nugg's active loan: calculates the current min eth a user must send to liquidate or rebalance
	/// @dev contract     ->
	/// @param tokenId    -> the token who's current loan to check
	/// @return isLoaned  -> indicating if the token is loaned
	/// @return account   -> indicating if the token is loaned
	/// @return prin      -> the current amount loaned out, plus the final rebalance fee
	/// @return fee       -> the fee a user must pay to rebalance (and extend) the loan on their nugg
	/// @return earn      -> the amount of eth the minSharePrice has increased since loan was last rebalanced
	/// @return expire    -> the epoch the loan becomes insolvent
	function debt(uint24 tokenId)
		external
		view
		returns (
			bool isLoaned,
			address account,
			uint96 prin,
			uint96 fee,
			uint96 earn,
			uint24 expire
		);

	/// @notice "Values For Liquadation"
	/// @dev used to tell user how much eth to send for liquidate
	function vfl(uint24[] calldata tokenIds) external view returns (uint96[] memory res);

	/// @notice "Values For Rebalance"
	/// @dev used to tell user how much eth to send for rebalance
	function vfr(uint24[] calldata tokenIds) external view returns (uint96[] memory res);

	/* ///////////////////////////////////////////////////////////////////
                           	 TRUSTED
    /////////////////////////////////////////////////////////////////// */

	function isTrusted(address user) external view returns (bool);
}

interface INuggftV1Raw {
	/* ///////////////////////////////////////////////////////////////////
	                           IMMUTABLES
    /////////////////////////////////////////////////////////////////// */

	function dotnuggv1() external view returns (IDotnuggV1);

	function xnuggftv1() external view returns (IxNuggftV1);

	function genesis() external view returns (uint256 res);

	function migrator() external view returns (address res);

	function early() external view returns (uint24 res);

	function earlySeed() external view returns (uint256 res);

	/* ///////////////////////////////////////////////////////////////////
	                           GLOBAL STATE VARS
    /////////////////////////////////////////////////////////////////// */

	function stake() external view returns (uint256 res);

	/* ///////////////////////////////////////////////////////////////////
	                           MAPS
    /////////////////////////////////////////////////////////////////// */

	function agency(uint24 tokenId) external view returns (uint256 res);

	function offers(uint24 tokenId, address account) external view returns (uint256 value);

	function itemAgency(uint24 sellingTokenId, uint16 itemId) external view returns (uint256 res);

	function itemOffers(
		uint24 buyingTokenid,
		uint24 sellingTokenId,
		uint16 itemId
	) external view returns (uint256 res);

	function lastItemSwap(uint16 itemId) external view returns (uint256 res);

	function proof(uint24 tokenId) external view returns (uint256 res);

	function identity(address user) external view returns (address real);
}

interface INuggftV1Event {
	/* ///////////////////////////////////////////////////////////////////
                            EPOCH
    /////////////////////////////////////////////////////////////////// */

	event Genesis(
		uint256 blocknum,
		uint32 blockInterval,
		uint24 epochOffset,
		uint8 saleLen,
		uint24 early,
		address dotnugg,
		address xnuggftv1,
		bytes32 stake,
		uint8 agencyEthBits,
		uint96 loss
	);

	/* ///////////////////////////////////////////////////////////////////
                            PROOF
    /////////////////////////////////////////////////////////////////// */

	event Rotate(uint24 indexed tokenId, bytes32 proof);

	event MigrateV1Sent(address v2, uint24 tokenId, bytes32 proof, address owner, uint96 eth);

	/* ///////////////////////////////////////////////////////////////////
                            STAKE
    /////////////////////////////////////////////////////////////////// */

	event Extract(uint96 eth);

	event Stake(bytes32 stake);

	/* ///////////////////////////////////////////////////////////////////
                            NUGG SWAPS
    /////////////////////////////////////////////////////////////////// */

	event Offer(uint24 indexed tokenId, bytes32 agency, bytes32 stake);

	event OfferMint(uint24 indexed tokenId, bytes32 agency, bytes32 proof, bytes32 stake);

	event PreMint(uint24 indexed tokenId, bytes32 proof, bytes32 nuggAgency, uint16 indexed itemId, bytes32 itemAgency);

	// event Claim(uint24 indexed tokenId, address indexed account);

	// Claim(uint40,bytes32,bytes32,bytes32)
	event Claim(uint40 indexed tokenId, bytes32 proof, bytes32 offerAgency, bytes32 agency);

	event Sell(uint24 indexed tokenId, bytes32 agency);

	/* ///////////////////////////////////////////////////////////////////
                            ITEM SWAPS
    /////////////////////////////////////////////////////////////////// */

	event OfferItem(uint24 indexed sellingTokenId, uint16 indexed itemId, bytes32 agency, bytes32 stake);

	event ClaimItem(uint24 indexed sellingTokenId, uint16 indexed itemId, uint24 indexed buyerTokenId, bytes32 proof);

	event SellItem(uint24 indexed sellingTokenId, uint16 indexed itemId, bytes32 agency, bytes32 proof);

	/* ///////////////////////////////////////////////////////////////////
                            LOANS
    /////////////////////////////////////////////////////////////////// */

	event Loan(uint24 indexed tokenId, bytes32 agency);

	event Rebalance(uint24 indexed tokenId, bytes32 agency);

	event Liquidate(uint24 indexed tokenId, bytes32 agency);

	/* ///////////////////////////////////////////////////////////////////
                            TRUST
    /////////////////////////////////////////////////////////////////// */

	event TrustUpdated(address indexed user, bool trust);

	event MigratorV1Updated(address migrator);
}

interface INuggftV1Execute {
	/* ///////////////////////////////////////////////////////////////////
                            EPOCH
    /////////////////////////////////////////////////////////////////// */

	function multicall(bytes[] calldata data) external;

	/* ///////////////////////////////////////////////////////////////////
                            EPOCH
    /////////////////////////////////////////////////////////////////// */

	// none

	/* ///////////////////////////////////////////////////////////////////
                            PROOF
    /////////////////////////////////////////////////////////////////// */

	function rotate(
		uint24 tokenId,
		uint8[] calldata from,
		uint8[] calldata to
	) external;

	function migrate(uint24 tokenId) external;

	/* ///////////////////////////////////////////////////////////////////
                            STAKE
    /////////////////////////////////////////////////////////////////// */

	// none

	/* ///////////////////////////////////////////////////////////////////
                            NUGG SWAPS
    /////////////////////////////////////////////////////////////////// */

	function offer(
		uint24 buyerTokenId,
		uint24 sellerTokenId,
		uint16 itemId
	) external payable;

	function sell(
		uint24 sellerTokenId,
		uint16 itemid,
		uint96 floor
	) external;

	/* ///////////////////////////////////////////////////////////////////
                            ITEM SWAPS
    /////////////////////////////////////////////////////////////////// */

	function offer(uint24 tokenId) external payable;

	function offer(
		uint24 tokenIdToClaim,
		uint24 nuggToBidOn,
		uint16 itemId,
		uint96 value1,
		uint96 value2
	) external payable;

	function claim(
		uint24[] calldata tokenIds,
		address[] calldata accounts,
		uint24[] calldata buyingTokenIds,
		uint16[] calldata itemIds
	) external;

	function sell(uint24 tokenId, uint96 floor) external;

	/* ///////////////////////////////////////////////////////////////////
                            LOANS
    /////////////////////////////////////////////////////////////////// */

	function rebalance(uint24[] calldata tokenIds) external payable;

	function loan(uint24[] calldata tokenIds) external;

	function liquidate(uint24 tokenId) external payable;

	/* ///////////////////////////////////////////////////////////////////
                           	 TRUSTED
    /////////////////////////////////////////////////////////////////// */

	/// @notice sends the current protocolEth to the user and resets the value to zero
	/// @dev caller must be a trusted user
	function extract() external;

	/// @notice sets the migrator contract
	/// @dev caller must be a trusted user
	/// @param migrator the address to set as the migrator contract
	function setMigrator(address migrator) external;

	function setIsTrusted(address user, bool trust) external;

	/* ///////////////////////////////////////////////////////////////////
                            OTHER
    /////////////////////////////////////////////////////////////////// */

	/// @notice updates the sending user's identity to the new address passed
	function setIdentity(address to) external;
}

interface INuggftV1 is IERC721, IERC721Metadata, INuggftV1Raw, INuggftV1Event, INuggftV1Execute, INuggftV1Lens {}
