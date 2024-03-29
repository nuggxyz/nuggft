// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./claim/revert__claim__0x67.sol";
import "./claim/revert__claim__0x74.sol";
import "./claim/revert__claim__0x75.sol";
import "./claim/revert__claim__0x76.sol";
import "./claim/revert__claim__0x79.sol";
import "./claim/revert__claim__0xA0.sol";
import "./claim/revert__claim__0xA5.sol";

import "./liquidate/revert__liquidate__0x75.sol";
import "./liquidate/revert__liquidate__0xA6.sol";
import "./liquidate/revert__liquidate__0xA7.sol";
import "./liquidate/revert__liquidate__0xA8.sol";

import "./loan/revert__loan__0x75.sol";
import "./loan/revert__loan__0x77.sol";
import "./loan/revert__loan__0xA1.sol";

import "./mint/revert__mint__0x65.sol";
import "./mint/revert__mint__0x66.sol";
import "./mint/revert__mint__0x71.sol";

import "./offer/revert__offer__0x68.sol";
import "./offer/revert__offer__0x71.sol";
import "./offer/revert__offer__0x72.sol";
import "./offer/revert__offer__0x99.sol";

import "./offer/revert__offer__0xA0.sol";
import "./offer/revert__offer__0xA2.sol";
import "./offer/revert__offer__0xA3.sol";
import "./offer/revert__offer__0xA4.sol";
import "./offer/revert__offer__0xAC.sol";

import "./rebalance/revert__rebalance__0x75.sol";
import "./rebalance/revert__rebalance__0xA4.sol";
import "./rebalance/revert__rebalance__0xAA.sol";
import "./rebalance/revert__rebalance__0xA8.sol";

import "./sell/revert__sell__0x70.sol";
import "./sell/revert__sell__0x77.sol";
import "./sell/revert__sell__0x97.sol";
import "./sell/revert__sell__0xA2.sol";
import "./sell/revert__sell__0xA3.sol";
import "./sell/revert__sell__0xA9.sol";

import "../../utils/forge.sol";

contract Revert2 is
	revert__claim__0x67,
	revert__claim__0x74,
	revert__claim__0x75,
	revert__claim__0x76,
	revert__claim__0x79,
	revert__claim__0xA0,
	revert__claim__0xA5,
	revert__liquidate__0x75,
	revert__liquidate__0xA6,
	revert__liquidate__0xA7,
	revert__liquidate__0xA8,
	revert__loan__0x75,
	revert__loan__0x77,
	revert__loan__0xA1,
	revert__mint__0x65,
	revert__mint__0x66,
	revert__mint__0x71,
	revert__offer__0x68,
	revert__offer__0x71,
	revert__offer__0x72,
	revert__offer__0x99,
	revert__offer__0xA0,
	revert__offer__0xA2,
	revert__offer__0xA3,
	revert__offer__0xA4,
	revert__offer__0xAC,
	revert__rebalance__0x75,
	revert__rebalance__0xA4,
	revert__rebalance__0xAA,
	revert__rebalance__0xA8,
	revert__sell__0x70,
	revert__sell__0x77,
	revert__sell__0x97,
	revert__sell__0xA2,
	revert__sell__0xA3,
	revert__sell__0xA9
{
	function setUp() public {
		reset();
	}
}
