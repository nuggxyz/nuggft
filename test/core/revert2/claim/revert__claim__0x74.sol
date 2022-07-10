// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "@nuggft-v1-core/test/main.sol";

/// Error__0x74__Untrusted
/// desc: this error is thrown when the user is not someone that can receive funds for the user who owns them

abstract contract revert__claim__0x74 is NuggftV1Test {
	using NuggftV1AgentType for uint256;

	uint24 FRANKS_TOKEN;
	uint24 FRANKS_TOKEN_2;

	uint24 CHARLIES_TOKEN;
	uint24 DENNISS_TOKEN;

	uint16 ITEM_ID;

	modifier revert__claim__0x74_setUp() {
		FRANKS_TOKEN = mintable(0);
		FRANKS_TOKEN_2 = mintable(5);

		CHARLIES_TOKEN = mintable(1);
		DENNISS_TOKEN = mintable(2);
		// mint required tokens
		mintHelper(FRANKS_TOKEN, users.frank, nuggft.msp());
		mintHelper(FRANKS_TOKEN_2, users.frank, nuggft.msp());

		mintHelper(CHARLIES_TOKEN, users.charlie, nuggft.msp());
		mintHelper(DENNISS_TOKEN, users.dennis, nuggft.msp());

		// frank gets a sellable itemId
		ITEM_ID = uint16(xnuggft.floop(FRANKS_TOKEN_2)[2]);

		// frank puts the item and the nugg up for sale
		expect.sell().from(users.frank).exec(FRANKS_TOKEN, 2 ether);
		expect.sell().from(users.frank).exec(FRANKS_TOKEN_2, ITEM_ID, 2 ether);

		// jump to epoch 3500
		jumpUp(500);

		// DEE makes a LOSING NUGG offer
		expect.offer().from(users.dee).exec{value: nuggft.vfo(users.dee, FRANKS_TOKEN)}(FRANKS_TOKEN);

		// MAC makes a WINNING NUGG offer
		expect.offer().from(users.mac).exec{value: nuggft.vfo(users.mac, FRANKS_TOKEN)}(FRANKS_TOKEN);

		// CHARLIE makes a LOSING ITEM offer
		expect.offer().from(users.charlie).exec{value: 2.2 ether}(CHARLIES_TOKEN, FRANKS_TOKEN_2, ITEM_ID);

		// DENNIS makes a WINNING ITEM offer
		expect.offer().from(users.dennis).exec{value: 3 ether}(DENNISS_TOKEN, FRANKS_TOKEN_2, ITEM_ID);

		// jump to an epoch where the offer can be claimed
		jumpSwap();
		_;
	}

	function test__revert__claim__0x74__pass__nugg__correctSenderCorrectArg() public revert__claim__0x74_setUp {
		expect.claim().from(users.mac).exec(FRANKS_TOKEN, users.mac);
	}

	function test__revert__claim__0x74__pass__item__nonWinningIncorrectSenderIncorrectArg() public revert__claim__0x74_setUp {
		expect.claim().from(users.charlie).exec(FRANKS_TOKEN_2, CHARLIES_TOKEN, ITEM_ID);

		expect.claim().from(users.charlie).exec(FRANKS_TOKEN_2, DENNISS_TOKEN, ITEM_ID);

		expect.claim().from(users.frank).exec(FRANKS_TOKEN_2, FRANKS_TOKEN_2, ITEM_ID);
	}

	function test__revert__claim__0x74__fail__item__userWithPendingWinningNuggClaim() public revert__claim__0x74_setUp {
		expect.claim().err(0x74).from(users.mac).exec(FRANKS_TOKEN_2, uint24(uint160(users.mac)), ITEM_ID);
	}

	function test__revert__claim__0x74__fail__nugg__incorrectSenderCorrectArg() public revert__claim__0x74_setUp {
		expect.claim().err(0x74).from(users.dee).exec(FRANKS_TOKEN_2, uint24(uint160(users.mac)), ITEM_ID);
	}

	function test__revert__claim__0x74__fail__item__nonWinningIncorrectSenderIncorrectArgIncorrectUser() public revert__claim__0x74_setUp {
		expect.claim().err(0x74).from(users.dee).exec(FRANKS_TOKEN_2, CHARLIES_TOKEN, ITEM_ID);
	}

	// function test__revert__claim__0x74__fail__item__correctUserIncorrectNugg() public revert__claim__0x74_setUp {
	//     assert(false);
	// }

	// function test__revert__claim__0x74__pass__item__correctUserCorrectNugg() public revert__claim__0x74_setUp {
	//     assert(false);
	// }
}
