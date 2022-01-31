// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {IDotnuggV1Metadata} from '../interfaces/dotnuggv1/IDotnuggV1Metadata.sol';

import {MockDotnuggV1} from './mock/MockDotnuggV1.sol';

import {MockNuggftV1Migrator} from './mock/MockNuggftV1Migrator.sol';

import {NuggftV1} from '../NuggftV1.sol';
import {PureDeployer} from '../_deployment/PureDeployer.sol';

import {Expect} from './expect/Expect.sol';

import './utils/forge.sol';

import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';

contract RiggedNuggft is NuggftV1 {
    constructor() {
        // featureLengths = 0x0303030303030303;
    }

    function getBlockHash(uint256 blocknum) internal view override returns (bytes32 res) {
        if (block.number > blocknum && block.number - blocknum < 256) {
            return keccak256(abi.encodePacked(blocknum));
        }
    }

    function external__calculateSeed() external view returns (uint256 res, uint24 _epoch) {
        return calculateSeed();
    }

    function external__calculateSeed(uint24 epoch) external view returns (uint256 res) {
        return calculateSeed(epoch);
    }

    function external__agency(uint160 tokenId) external view returns (uint256 res) {
        return agency[tokenId];
    }

    function external__offers(uint160 tokenId, address user) external view returns (uint256 res) {
        return offers[tokenId][user];
    }

    function external__itemAgency(uint160 tokenId) external view returns (uint256 res) {
        return itemAgency[tokenId];
    }

    function external__itemOffers(uint160 tokenId, uint160 buyer) external view returns (uint256 res) {
        return itemOffers[tokenId][buyer];
    }

    function external__stake() external view returns (uint256 res) {
        return stake;
    }

    function external__toStartBlock(uint24 _epoch) public view returns (uint256 res) {
        return toStartBlock(_epoch, genesis);
    }

    function external__agency__slot() public view returns (bytes32 res) {
        assembly {
            res := agency.slot
        }
    }
}

library SafeCast {
    function safeInt(uint96 input) internal pure returns (int192) {
        return (int192(int256(uint256(input))));
    }
}

contract NuggftV1Test is ForgeTest {
    using SafeCast for uint96;
    using SafeCast for uint256;
    using SafeCast for uint64;

    MockDotnuggV1 public processor;

    MockNuggftV1Migrator public _migrator;

    RiggedNuggft internal nuggft;

    constructor() {}

    address public _nuggft;
    address public _processor;
    address public _proxy;

    struct Users {
        address frank;
        address dee;
        address mac;
        address dennis;
        address charlie;
        address safe;
    }

    Users public users;

    Expect expect;

    address internal dub6ix = 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77;

    // constructor() {}

    function reset() public {
        forge.vm.roll(1000);
        // bytes memory tmp = hex'000100';
        ds.setDsTest(address(this));

        PureDeployer dep = new PureDeployer(0, 0, type(RiggedNuggft).creationCode, type(MockDotnuggV1).creationCode, tmpdata);
        // dep.init();

        processor = MockDotnuggV1(dep.__dotnugg());
        nuggft = RiggedNuggft(dep.__nuggft());

        _nuggft = address(nuggft);

        expect = new Expect(_nuggft);

        _processor = address(processor);

        _migrator = new MockNuggftV1Migrator();

        users.frank = forge.vm.addr(12);
        forge.vm.deal(users.frank, 90000 ether);

        users.dee = forge.vm.addr(13);
        forge.vm.deal(users.dee, 90000 ether);

        users.mac = forge.vm.addr(14);
        forge.vm.deal(users.mac, 90000 ether);

        users.dennis = forge.vm.addr(15);
        forge.vm.deal(users.dennis, 90000 ether);

        users.charlie = forge.vm.addr(16);
        forge.vm.deal(users.charlie, 90000 ether);

        users.safe = forge.vm.addr(17);
        forge.vm.deal(users.safe, 90000 ether);

        forge.vm.startPrank(0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
        nuggft.setIsTrusted(users.safe, true);
        forge.vm.stopPrank();
    }

    function reset__system() public {
        forge.vm.roll(14069560);
        ds.setDsTest(address(this));

        PureDeployer dep = new PureDeployer(0, 0, type(RiggedNuggft).creationCode, type(MockDotnuggV1).creationCode, tmpdata);
        // dep.init();

        processor = MockDotnuggV1(dep.__dotnugg());
        nuggft = RiggedNuggft(dep.__nuggft());

        // record.build(nuggft.external__agency__slot());

        _nuggft = address(nuggft);

        expect = new Expect(_nuggft);

        _processor = address(processor);

        _migrator = new MockNuggftV1Migrator();

        users.frank = forge.vm.addr(12);
        forge.vm.deal(users.frank, 90000 ether);

        users.dee = forge.vm.addr(13);
        forge.vm.deal(users.dee, 90000 ether);

        users.mac = forge.vm.addr(14);
        forge.vm.deal(users.mac, 90000 ether);

        users.dennis = forge.vm.addr(15);
        forge.vm.deal(users.dennis, 90000 ether);

        users.charlie = forge.vm.addr(16);
        forge.vm.deal(users.charlie, 90000 ether);

        users.safe = forge.vm.addr(17);
        forge.vm.deal(users.safe, 90000 ether);

        forge.vm.startPrank(0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
        nuggft.setIsTrusted(users.safe, true);
        forge.vm.stopPrank();
    }

    function reset__revert() public {
        forge.vm.roll(14069560);

        PureDeployer dep = new PureDeployer(0, 0, type(RiggedNuggft).creationCode, type(MockDotnuggV1).creationCode, tmpdata);

        processor = MockDotnuggV1(dep.__dotnugg());
        nuggft = RiggedNuggft(dep.__nuggft());

        _nuggft = address(nuggft);

        expect = new Expect(_nuggft);

        _processor = address(processor);

        users.frank = forge.vm.addr(12);

        users.dee = forge.vm.addr(13);

        users.mac = forge.vm.addr(14);

        users.dennis = forge.vm.addr(15);

        users.charlie = forge.vm.addr(16);

        users.safe = forge.vm.addr(17);

        forge.vm.startPrank(0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
        nuggft.setIsTrusted(users.safe, true);
        forge.vm.stopPrank();
    }

    function reset__fork() public {
        ds.setDsTest(address(this));

        PureDeployer dep = new PureDeployer(0, 0, type(RiggedNuggft).creationCode, type(MockDotnuggV1).creationCode, tmpdata);
        // dep.init();

        processor = MockDotnuggV1(dep.__dotnugg());
        nuggft = RiggedNuggft(dep.__nuggft());

        // record.build(nuggft.external__agency__slot());

        _nuggft = address(nuggft);

        expect = new Expect(_nuggft);

        _processor = address(processor);

        _migrator = new MockNuggftV1Migrator();

        users.frank = forge.vm.addr(12);
        forge.vm.deal(users.frank, 90000 ether);

        users.dee = forge.vm.addr(13);
        forge.vm.deal(users.dee, 90000 ether);

        users.mac = forge.vm.addr(14);
        forge.vm.deal(users.mac, 90000 ether);

        users.dennis = forge.vm.addr(15);
        forge.vm.deal(users.dennis, 90000 ether);

        users.charlie = forge.vm.addr(16);
        forge.vm.deal(users.charlie, 90000 ether);

        users.safe = forge.vm.addr(17);
        forge.vm.deal(users.safe, 90000 ether);

        forge.vm.startPrank(0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
        nuggft.setIsTrusted(users.safe, true);
        forge.vm.stopPrank();
    }

    function jump(uint24 to) public {
        uint256 startblock = nuggft.external__toStartBlock(to);
        forge.vm.roll(startblock);
    }

    function encItemId(
        uint160 buyerTokenId,
        uint160 tokenId,
        uint16 itemId
    ) internal pure returns (uint160) {
        return uint160((buyerTokenId << 40) | (uint256(itemId) << 24)) | tokenId;
    }

    function encItemIdClaim(uint160 tokenId, uint16 itemId) internal pure returns (uint160) {
        return uint160(uint256(itemId) << 24) | tokenId;
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                eth modifiers
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    modifier baldiff(address user, int192 exp) {
        int192 got = int192(int256(uint256(address(nuggft).balance)));
        _;
        got = int192(int256(uint256(address(nuggft).balance))) - got;

        assertEq(got, exp, 'balance did not change correctly');
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            expectBalanceChange
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    struct BalDiff {
        address user;
        uint256 expected;
    }

    BalDiff[] _baldiffarr;
    enum Direction {
        down,
        up
    }

    function expectBalChange(
        address user,
        uint96 exp,
        Direction direction
    ) internal {
        _baldiffarr.push(
            BalDiff({
                user: user, //
                expected: (direction == Direction.up ? user.balance + exp : user.balance - exp)
            })
        );
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            expectBalanceChange
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    event StakeSnapshotTaken(bytes32 data, uint96 staked, uint96 protocol, uint96 shares, uint96 msp, uint96 eps);

    struct StakeSnapshot {
        uint256 data;
        uint96 staked;
        uint96 proto;
        uint96 shares;
        uint96 msp;
        uint96 eps;
    }

    function stakeHelper() internal returns (StakeSnapshot memory a) {
        uint256 stake__cache = nuggft.external__stake();

        a = StakeSnapshot({
            data: stake__cache, //
            staked: nuggft.staked(),
            proto: nuggft.proto(),
            shares: nuggft.shares(),
            msp: nuggft.msp(),
            eps: nuggft.eps()
        });

        emit StakeSnapshotTaken(bytes32(a.data), a.staked, a.proto, a.shares, a.msp, a.eps);

        //   console.log();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            expectBalanceChange
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    struct AgencySnapshot {
        uint160 tokenId;
        uint256 data;
        uint8 flag;
        uint24 epoch;
        uint96 ethDecompressed;
        uint72 ethCompressed;
        address account;
    }

    mapping(uint160 => AgencySnapshot) agencySnapshots;

    event AgencySnapshotTaken(uint160 tokenId, bytes32 data, uint8 flag, uint24 epoch, uint96 ethDecompressed, uint72 ethCompressed, address account);

    function agencyHelper(uint160 tokenId) private returns (AgencySnapshot memory a) {
        uint256 agency__cache = nuggft.external__agency(tokenId);

        uint256 eth = (agency__cache >> 160) & ((1 << 70) - 1);

        a = AgencySnapshot({
            tokenId: tokenId,
            data: agency__cache,
            flag: uint8(agency__cache >> 254),
            epoch: uint24(agency__cache >> 230),
            ethDecompressed: uint96(eth * .1 gwei),
            ethCompressed: uint72(eth),
            account: address(uint160(agency__cache))
        });

        emit AgencySnapshotTaken(a.tokenId, bytes32(a.data), a.flag, a.epoch, a.ethDecompressed, a.ethCompressed, a.account);
    }

    function offerHelper(uint160 tokenId, address user) private returns (AgencySnapshot memory a) {
        uint256 agency__cache = nuggft.external__offers(tokenId, user);

        uint256 eth = (agency__cache >> 160) & ((1 << 70) - 1);

        a = AgencySnapshot({
            tokenId: tokenId,
            data: agency__cache,
            flag: uint8(agency__cache >> 254),
            epoch: uint24(agency__cache >> 230),
            ethDecompressed: uint96(eth * .1 gwei),
            ethCompressed: uint72(eth),
            account: address(uint160(agency__cache))
        });

        emit AgencySnapshotTaken(a.tokenId, bytes32(a.data), a.flag, a.epoch, a.ethDecompressed, a.ethCompressed, a.account);
    }

    function itemAgencyHelper(uint160 tokenId) private returns (AgencySnapshot memory a) {
        uint256 itemAgency__cache = nuggft.external__itemAgency(tokenId);

        uint256 eth = (itemAgency__cache >> 160) & ((1 << 70) - 1);

        a = AgencySnapshot({
            tokenId: tokenId,
            data: itemAgency__cache,
            flag: uint8(itemAgency__cache >> 254),
            epoch: uint24(itemAgency__cache >> 230),
            ethDecompressed: uint96(eth * .1 gwei),
            ethCompressed: uint72(eth),
            account: address(uint160(itemAgency__cache))
        });

        emit AgencySnapshotTaken(a.tokenId, bytes32(a.data), a.flag, a.epoch, a.ethDecompressed, a.ethCompressed, a.account);
    }

    function itemOfferHelper(uint160 tokenId, uint160 buyer) private returns (AgencySnapshot memory a) {
        uint256 itemAgency__cache = nuggft.external__itemOffers(tokenId, buyer);

        uint256 eth = (itemAgency__cache >> 160) & ((1 << 70) - 1);

        a = AgencySnapshot({
            tokenId: tokenId,
            data: itemAgency__cache,
            flag: uint8(itemAgency__cache >> 254),
            epoch: uint24(itemAgency__cache >> 230),
            ethDecompressed: uint96(eth * .1 gwei),
            ethCompressed: uint72(eth),
            account: address(uint160(itemAgency__cache))
        });

        emit AgencySnapshotTaken(a.tokenId, bytes32(a.data), a.flag, a.epoch, a.ethDecompressed, a.ethCompressed, a.account);
    }

    function recordAgencySnapshot(uint160 tokenId) internal returns (AgencySnapshot memory a) {
        a = agencyHelper(tokenId);

        agencySnapshots[tokenId] = a;
    }

    function assertAgency(
        uint160 tokenId,
        uint8 flag,
        uint24 epoch,
        uint96 eth,
        address account
    ) internal {
        AgencySnapshot memory a = agencyHelper(tokenId);

        assertEq(a.flag, flag, 'assertAgency: flag');
        assertEq(a.epoch, epoch, 'assertAgency: epoch');
        assertEq(a.ethDecompressed, eth, 'assertAgency: eth');
        assertEq(a.account, account, 'assertAgency: account');
    }

    function assertAgencyFlagChange(
        uint160 tokenId,
        uint8 from,
        uint8 to
    ) internal {
        AgencySnapshot memory snap = agencySnapshots[tokenId];
        AgencySnapshot memory curr = agencyHelper(tokenId);
        assertEq(snap.flag, from, 'assertAgencyFlagChange: from');
        assertEq(curr.flag, to, 'assertAgencyFlagChange: to');
    }

    function assertAgencyEpochChange(
        uint160 tokenId,
        uint24 from,
        uint24 to
    ) internal {
        AgencySnapshot memory snap = agencySnapshots[tokenId];
        AgencySnapshot memory curr = agencyHelper(tokenId);
        assertEq(snap.epoch, from, 'assertAgencyEpochChange: from');
        assertEq(curr.epoch, to, 'assertAgencyEpochChange: to');
    }

    function assertAgencyEthChange(
        uint160 tokenId,
        uint96 from,
        uint96 to
    ) internal {
        AgencySnapshot memory snap = agencySnapshots[tokenId];
        AgencySnapshot memory curr = agencyHelper(tokenId);
        assertEq(snap.ethDecompressed, from, 'assertAgencyEthChange: from');
        assertEq(curr.ethDecompressed, to, 'assertAgencyEthChange: to');
    }

    function assertAgencyAccountChange(
        uint160 tokenId,
        address from,
        address to
    ) internal {
        AgencySnapshot memory snap = agencySnapshots[tokenId];
        AgencySnapshot memory curr = agencyHelper(tokenId);
        assertEq(snap.account, from, 'assertAgencyAccountChange: from');
        assertEq(curr.account, to, 'assertAgencyAccountChange: to');
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                expectOfferSnapshot
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // struct ExpectOfferSnapshot {
    //     uint160 tokenId;
    //     address user;
    //     uint96 amount;
    //     StakeSnapshot stake;
    //     AgencySnapshot agency;
    //     AgencySnapshot prevOffer;
    //     uint96 nuggftBalance;
    //     uint96 userBalance;
    //     address owner;
    //     address sender;
    // }

    // ExpectOfferSnapshot expectOfferSnapshot;

    // function startExpectOffer(
    //     uint160 tokenId,
    //     address by,
    //     uint96 amount
    // ) internal {
    //     expectOfferSnapshot = ExpectOfferSnapshot(
    //         tokenId,
    //         by,
    //         amount,
    //         stakeHelper(),
    //         agencyHelper(tokenId),
    //         offerHelper(tokenId, by),
    //         uint96(address(nuggft).balance),
    //         uint96(by.balance),
    //         address(0),
    //         by
    //     );

    //     emit log_named_int('a', 333);

    //     if (expectOfferSnapshot.agency.data != 0) {
    //         emit log_named_int('a', 444);

    //         expectOfferSnapshot.owner = nuggft.ownerOf(tokenId);
    //     }
    // }

    // function endExpectOffer() internal {
    //     ExpectOfferSnapshot memory snap = expectOfferSnapshot;
    //     delete expectOfferSnapshot;

    //     StakeSnapshot memory beforeStake = snap.stake;
    //     AgencySnapshot memory beforeAgency = snap.agency;

    //     StakeSnapshot memory afterStake = stakeHelper();
    //     AgencySnapshot memory afterAgency = agencyHelper(snap.tokenId);

    //     if (beforeAgency.data == 0) {
    //         // MINT
    //         assertEq(beforeStake.shares + 1, afterStake.shares, 'Offer:Mint -> expect shares to increase by one');
    //     } else {
    //         // NOT MINT
    //         assertEq(beforeStake.shares, afterStake.shares, 'Offer:NotMint -> expect shares to stay the same');
    //         if (beforeAgency.epoch == 0) {
    //             // COMMIT
    //         } else {
    //             // CARRY
    //         }
    //     }

    //     assertEq(afterAgency.ethDecompressed, snap.amount + snap.prevOffer.ethDecompressed, 'Offer -> expect agency eth to increaase by an amount');

    //     assertEq(snap.user.balance, snap.userBalance - snap.amount, 'Offer -> expect user balance to decrease by aamount');
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                expectAllSnapshot
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                encodeWithSelector
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // struct ExpectMintSnapshot {
    //     uint160 tokenId;
    //     address user;
    //     uint96 value;
    //     StakeSnapshot stake;
    //     AgencySnapshot agency;
    // }

    // ExpectMintSnapshot expectMintSnapshot;

    // function startExpectMint(
    //     uint160 tokenId,
    //     address by,
    //     uint96 amount
    // ) internal {
    //     expectMintSnapshot = ExpectMintSnapshot(tokenId, by, amount, stakeHelper(), agencyHelper(tokenId));
    // }

    // function endExpectMint() internal {
    //     ExpectMintSnapshot memory snap = expectMintSnapshot;
    //     delete expectMintSnapshot;

    //     StakeSnapshot memory stake = stakeHelper();
    //     AgencySnapshot memory agency = agencyHelper(snap.tokenId);

    //     assertEq(snap.stake.shares + 1, stake.shares, 'mint -> expect shares to increase by one');
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                encodeWithSelector
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function check() internal {
        for (uint256 i = 0; i < _baldiffarr.length; i++) {
            assertEq(_baldiffarr[i].user.balance, _baldiffarr[i].expected, 'checkBalChange');
            delete _baldiffarr[i];
        }

        // checkStakeChange();
    }

    function take(int256 percent, int256 value) internal pure returns (int256) {
        return (value * percent) / 100;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function scenario_dee_has_a_token() public payable returns (uint160 tokenId) {
        tokenId = 2069;

        forge.vm.prank(users.dee);
        nuggft.mint(tokenId);
    }

    function scenario_frank_has_a_token_and_spent_50_eth() public payable returns (uint160 tokenId) {
        tokenId = 2012;

        forge.vm.prank(users.frank);
        nuggft.mint{value: 50 ether}(tokenId);
    }

    function scenario_frank_has_a_loaned_token() public payable returns (uint160 tokenId) {
        scenario_charlie_has_a_token();

        tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        // forge.vm.prank(users.frank);
        // nuggft.approve(_nuggft, tokenId);

        forge.vm.prank(users.frank);
        nuggft.loan(lib.sarr160(tokenId));
    }

    function scenario_frank_has_a_loaned_token_that_has_expired() public payable returns (uint160 tokenId) {
        tokenId = scenario_frank_has_a_loaned_token();

        forge.vm.roll(2000000);
    }

    function scenario_dee_has_a_token_2() public payable returns (uint160 tokenId) {
        tokenId = 2400;

        forge.vm.prank(users.dee);
        nuggft.mint(tokenId);
    }

    function scenario_charlie_has_a_token() public payable returns (uint160 tokenId) {
        tokenId = 2070;

        forge.vm.prank(users.charlie);
        nuggft.mint(tokenId);
    }

    function scenario_migrator_set() public payable {
        forge.vm.prank(users.safe);
        nuggft.setMigrator(address(_migrator));
    }

    function scenario_dee_has_a_token_and_can_sell() public payable returns (uint160 tokenId) {
        tokenId = scenario_dee_has_a_token();

        // forge.vm.prank(users.dee);
        // nuggft.approve(_nuggft, tokenId);
    }

    function scenario_dee_has_sold_a_token() public payable returns (uint160 tokenId, uint96 floor) {
        tokenId = scenario_dee_has_a_token_and_can_sell();

        floor = 1 ether;

        forge.vm.prank(users.dee);
        nuggft.sell(tokenId, floor);
    }

    function scenario_dee_has_sold_a_token_and_mac_has_offered() public payable returns (uint160 tokenId, uint96 eth) {
        (tokenId, ) = scenario_dee_has_sold_a_token();

        eth = 2 ether;

        forge.vm.prank(users.mac);
        nuggft.offer{value: eth}(tokenId);
    }

    function scenario_dee_has_sold_a_token_and_mac_can_claim() public payable returns (uint160 tokenId) {
        (tokenId, ) = scenario_dee_has_sold_a_token_and_mac_has_offered();

        forge.vm.roll(2000);
    }

    function scenario_mac_has_claimed_a_token_dee_sold() public payable returns (uint160 tokenId) {
        (tokenId) = scenario_dee_has_sold_a_token_and_mac_can_claim();

        forge.vm.prank(users.mac);
        nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(users.mac));
    }

    function scenario_mac_has_sold_a_token_dee_sold() public payable returns (uint160 tokenId, uint96 floor) {
        (tokenId) = scenario_mac_has_claimed_a_token_dee_sold();

        floor = 3 ether;

        // forge.vm.prank(users.mac);
        // nuggft.approve(_nuggft, tokenId);

        forge.vm.prank(users.mac);
        nuggft.sell(tokenId, floor);
    }

    function scenario_dee_has_a_token_and_can_sell_an_item()
        public
        payable
        returns (
            uint160 tokenId,
            uint16 itemId,
            uint8 feature
        )
    {
        (tokenId) = scenario_dee_has_a_token();

        IDotnuggV1Metadata.Memory memory m = nuggft.dotnuggV1ImplementerCallback(
            tokenId
            // IDotnuggV1Metadata.Memory({
            //     implementer: _nuggft,
            //     artifactId: tokenId,
            //     ids: new uint8[](8),
            //     xovers: new uint8[](8),
            //     yovers: new uint8[](8),
            //     version: 1,
            //     labels: new string[](8),
            //     jsonKeys: new string[](8),
            //     jsonValues: new string[](8),
            //     styles: new string[](8),
            //     background: '',
            //     data: ''
            // })
        );

        feature = 1;
        itemId = m.ids[feature] | (uint16(feature) << 8);

        // _nuggft.shouldPass(dee, rotate(tokenId, feature));
    }

    function scenario_dee_has_sold_an_item()
        public
        payable
        returns (
            uint160 tokenId,
            uint8 feature,
            uint16 itemId,
            uint96 floor
        )
    {
        (tokenId, itemId, feature) = scenario_dee_has_a_token_and_can_sell_an_item();
        floor = 3 ether;

        forge.vm.prank(users.dee);

        nuggft.sell(tokenId, itemId, floor);
    }

    function scenario_dee_has_sold_an_item_and_charlie_can_claim()
        public
        payable
        returns (
            uint160 charliesTokenId,
            uint160 tokenId,
            uint16 itemId
        )
    {
        uint256 feature;
        uint96 floor;
        (tokenId, feature, itemId, floor) = scenario_dee_has_sold_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        forge.vm.prank(users.charlie);

        nuggft.offer{value: floor + 1 ether}(uint160((charliesTokenId << 40) | (uint256(itemId) << 24)) | tokenId);

        forge.vm.roll(2000);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                encodeWithSelector
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function mintAs(
        uint160 tokenId,
        address user,
        uint96 value
    ) internal {
        forge.vm.deal(user, user.balance + value);
        forge.vm.prank(user);
        nuggft.mint{value: value}(tokenId);
    }

    function offerAs(
        uint160 tokenId,
        address user,
        uint96 value
    ) internal {
        forge.vm.deal(user, user.balance + value);
        forge.vm.prank(user);
        nuggft.offer{value: value}(tokenId);
    }

    function sellAs(
        uint160 tokenId,
        address user,
        uint96 value
    ) internal {
        forge.vm.prank(user);
        nuggft.sell(tokenId, value);
    }

    function claimAs(uint160 tokenId, address user) internal {
        forge.vm.prank(user);
        nuggft.claim(lib.sarr160(tokenId), lib.sarrAddress(user));
    }

    function rebalanceAs(
        uint160 tokenId,
        address user,
        uint96 value
    ) internal {
        forge.vm.deal(user, user.balance + value);
        forge.vm.prank(user);
        nuggft.rebalance(lib.sarr160(tokenId));
    }

    function loanAs(
        uint160 tokenId,
        address user,
        uint96 value
    ) internal {
        forge.vm.deal(user, user.balance + value);
        forge.vm.prank(user);
        nuggft.loan(lib.sarr160(tokenId));
    }

    function liquidateAs(
        uint160 tokenId,
        address user,
        uint96 value
    ) internal {
        forge.vm.deal(user, user.balance + value);
        forge.vm.prank(user);
        nuggft.liquidate{value: value}(tokenId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    // function environment() public returns (address[] memory users) {
    //     users = new address[](2000);

    //     User start = new User{value: 69 ether}();
    //     uint160 count = 501;

    //                 forge.vm.deal(address(start), 69 ether);

    //     nuggft_call(start, mint(count++), .01 ether);
    //     nuggft_call(start, mint(count++), nuggft.msp());
    //     nuggft_call(start, mint(count++), nuggft.msp());

    //     users[0] = address(start);

    //     for (uint256 i = 1; i < users.length; i++) {
    //         User tmp = new User{value: 69 ether}();

    //         forge.vm.deal(address(tmp), 69 ether);

    //         nuggft_call(tmp, mint(count++), nuggft.msp());
    //         nuggft_call(tmp, mint(count++), nuggft.msp());
    //         nuggft_call(tmp, mint(count++), nuggft.msp());

    //         users[i] = address(tmp);
    //     }

    // }

    // function environmentForge() public returns (address[] memory users) {
    //     users = new address[](9500);

    //     User start = new User{value: 1000000000 ether}();
    //     uint160 count = 501;

    //     //   forge.vm.deal(address(start), 10000 *10**18);

    //     _nuggft.shouldPass(start, mint(count++), .08 ether);

    //     users[0] = address(start);

    //     int256 last = 0;
    //     int256 lastDiff = 0;

    //     for (uint256 i = 1; i < users.length; i++) {
    //         // User tmp = new User{value: 100000000 ether}();

    //         // forge.vm.deal(address(tmp), 10000 *10**18);

    //         _nuggft.shouldPass(start, mint(count++), nuggft.msp());

    //         int256 curr = nuggft.msp().safeInt();

    //         users[i] = address(start);

    //         int256 diff = curr - last;
    //         emit log_named_int('diff', curr - last);
    //         emit log_named_int('ldif', diff - lastDiff);

    //         emit log_named_uint('nuggft.eps()', nuggft.eps());
    //         // emit log_named_uint('nuggft.proto()', nuggft.proto());
    //         // emit log_named_uint('nuggft.staked()', nuggft.staked());
    //         emit log_named_uint('nuggft.shares()', nuggft.shares());
    //         emit log_named_uint('nuggft.msp()', nuggft.msp());

    //         emit log_string('--------');

    //         last = curr;
    //         lastDiff = diff;
    //     }
    // }

    // function environmentForge2() public returns (address[] memory users) {
    //     users = environmentForge();

    //     uint256 bn = 5000;

    //     // for (uint256 i = 0; i < 10000; i++) {
    //     //     uint256 epoch = nuggft.epoch();

    //     //     uint256 funner = uint256(keccak256(abi.encodePacked(epoch))) % 100;

    //     //     nuggft_call(User(payable(users[funner])), offer(users[funner], epoch), nuggft.msp());

    //     //     forge.vm.roll(bn);

    //     //     bn += 70;

    //     //     nuggft_call(User(payable(users[funner])), claim(users[funner], epoch));
    //     // }

    //     assert(false);
    // }

    bytes tmpdata =
        hex'0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000346000000000000000000000000000000000000000000000000000000000000065600000000000000000000000000000000000000000000000000000000000008d80000000000000000000000000000000000000000000000000000000000000a9a0000000000000000000000000000000000000000000000000000000000000b520000000000000000000000000000000000000000000000000000000000000bd800000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000007000000000f01c9049082f04a4a8829211001f211010a188aa430a017228610a22a98a3122801b9218a18428620a9ac40148e40c2a818a98a88c41203030b198c400caaf98a19001240b39b000e30b598c00e18b79923862de639018b799098b59b098b799098a18b198c4ac2a82ae82b003028628628682868412030108a86288a88287000701842c62892b080703041aa22aa0620c0170306ac940a3007c4c2cc440fb901c805e3f8402c18b018f400283864285998530992665ac24792ea093b568f2545fb70942b0f924d67fd092593f1244a2bac99ac3ee240104206900100000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000001b3e07b029c8aa63401b0218692a60ac006c0861a4b1823001b06590828623001b061a4a5b20b285a9e43003285aa643003283aae43003042892bec00c10b20af90c90a90b190c90b790c90b790c90b790c90b790c90a990a5b06a7a24286c82c1aa5a4b3001b06a8e92cc006c1ca3a06a3001b27286928c80ec1a8ed036c78171be100b062c063d000a0e190a166614c264792ea0942b0f924d67fd09128aeb24964fc492665ac2281842069001000000000000000000000000000000000000000000000000000000000000005c0000000000000000000000000000000000000000000000000000000000000b800000000000000000000000000000000000000000000000000000000000000be00000000000000000000000000000000000000000000000000000000000000c400000000000000000000000000000000000000000000000000000000000000ca00000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000d600000000000000000000000000000000000000000000000000000000000000dc00000000000000000000000000000000000000000000000000000000000000e200000000000000000000000000000000000000000000000000000000000000e800000000000000000000000000000000000000000000000000000000000000ee00000000000000000000000000000000000000000000000000000000000000f400000000000000000000000000000000000000000000000000000000000000f800000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000106000000000000000000000000000000000000000000000000000000000000010c00000000000000000000000000000000000000000000000000000000000001120000000000000000000000000000000000000000000000000000000000000118000000000000000000000000000000000000000000000000000000000000011e0000000000000000000000000000000000000000000000000000000000000124000000000000000000000000000000000000000000000000000000000000012a000000000000000000000000000000000000000000000000000000000000012e0000000000000000000000000000000000000000000000000000000000000134000000000000000000000000000000000000000000000000000000000000013a00000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000146000000000000000000000000000000000000000000000000000000000000014c0000000000000000000000000000000000000000000000000000000000000154000000000000000000000000000000000000000000000000000000000000015a00000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000166000000000000000000000000000000000000000000000000000000000000016c00000000000000000000000000000000000000000000000000000000000001760000000000000000000000000000000000000000000000000000000000000182000000000000000000000000000000000000000000000000000000000000018a00000000000000000000000000000000000000000000000000000000000001920000000000000000000000000000000000000000000000000000000000000198000000000000000000000000000000000000000000000000000000000000019c00000000000000000000000000000000000000000000000000000000000001a200000000000000000000000000000000000000000000000000000000000001a800000000000000000000000000000000000000000000000000000000000001ae00000000000000000000000000000000000000000000000000000000000001b400000000000000000000000000000000000000000000000000000000000001bc00000000000000000000000000000000000000000000000000000000000001c400000000000000000000000000000000000000000000000000000000000001c800000000000000000000000000000000000000000000000000000000000001ce00000000000000000000000000000000000000000000000000000000000001d400000000000000000000000000000000000000000000000000000000000001da00000000000000000000000000000000000000000000000000000000000001e400000000000000000000000000000000000000000000000000000000000001ea00000000000000000000000000000000000000000000000000000000000001f000000000000000000000000000000000000000000000000000000000000001f600000000000000000000000000000000000000000000000000000000000001fa00000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000206000000000000000000000000000000000000000000000000000000000000020c00000000000000000000000000000000000000000000000000000000000002120000000000000000000000000000000000000000000000000000000000000218000000000000000000000000000000000000000000000000000000000000021e00000000000000000000000000000000000000000000000000000000000002240000000000000000000000000000000000000000000000000000000000000228000000000000000000000000000000000000000000000000000000000000022e0000000000000000000000000000000000000000000000000000000000000232000000000000000000000000000000000000000000000000000000000000023800000000000000000000000000000000000000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000246000000000000000000000000000000000000000000000000000000000000024c0000000000000000000000000000000000000000000000000000000000000252000000000000000000000000000000000000000000000000000000000000025800000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000000000000000000000000000266000000000000000000000000000000000000000000000000000000000000026e0000000000000000000000000000000000000000000000000000000000000274000000000000000000000000000000000000000000000000000000000000027c00000000000000000000000000000000000000000000000000000000000002820000000000000000000000000000000000000000000000000000000000000288000000000000000000000000000000000000000000000000000000000000028e0000000000000000000000000000000000000000000000000000000000000296000000000000000000000000000000000000000000000000000000000000029c00000000000000000000000000000000000000000000000000000000000002a400000000000000000000000000000000000000000000000000000000000002ac00000000000000000000000000000000000000000000000000000000000002b400000000000000000000000000000000000000000000000000000000000002bc00000000000000000000000000000000000000000000000000000000000002c400000000000000000000000000000000000000000000000000000000000002ca00000000000000000000000000000000000000000000000000000000000002d200000000000000000000000000000000000000000000000000000000000002da00000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000002e800000000000000000000000000000000000000000000000000000000000002f000000000000000000000000000000000000000000000000000000000000002f80000000000000000000000000000000000000000000000000000000000000302000000000000000000000000000000000000000000000000000000000000030a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000006182659060269071060269071060269060a41808a4185180948007046a04b0610a39445c6cbd3cffffffd3e9ded84981142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000206020612029a80a6a00a02204188088106200a06126206126201246470608e29a73ffffff4e5b8ef13ff9b634981942069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000028006800ea18202a18204a1849801849a02801a80081a800a0fc182388610ccb533cfa77b613ffffff4a02142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000040a400e40a48a48448848048a10a484488108480e484481e4044006430610e31a73e9ded848829420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000001a402710098290098290098018e018e1189c18230861cffffffd3b7ad9b490314206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000024080390202500650040440240450048248048050065044016402410610c3187396e3bc488394206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000418064182508500508458c40050c488e400408e4884d884581e502482e482403e402403e400550619049e73ffffff48841420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000482e418850450a48848a48848a400408648864044d80e41805043b0610e31c73c6c6c648849420690010000000000000000000000000000000000000000000000000000000000000002701e6180688680e68841c290680660a49a519e419a51801a01a51a01c01a118e0598019a099a039c039a0998099c18841281cffffffd3212b4a4905142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000006200e200200e200200e20020020020020028425802580623802182e21856210c18248c81c8059420690010000000000000000000000000000000000000000000000000000000000000001000000000000a058a10c00a08c00a0086018861788418238871c8061420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000024880392201640a0390282604c38c00802eb0428cb8028e30a38c02ca0a30630e30800800c380b0a00c3803801cc18448a893a4d834c84ad2933b568f4c99761d32f3e6a4f3ffffff4b069420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000480e484408039020564044024045004824804805006500390618c31873ffffff4887142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000280068048188081206089184046108808981188848848823d0610c29673b7ad9b4fa77b613ffffff49879420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000008003042900a200a40430090049811260080280288080488281848182470611029c45c6cbd396e3bc4cbda52d3c988142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000001a200668801a20066886884181182106384618ac18230859ccbcf9a93ffffff490894206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000006806682608019820261001984026100198400680602680638269826190c18428e51cffffffd3e9ded84909142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000002480e48440a40440a40040840a40040840a48840a40040840a40040a40440a404480e4825d0610e31a73ffffff48899420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000186119829a019a649a019c21068061021060461221a098e11849a0f986110c18440c81cccdd68532665ac490a1420690010000000000000000000000000000000000000000000000000000000000000001070470260840460840263806387418230659cf1b1b1936a6a69490a94206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000008c018c112280e28447844580438443816404400e2b0611029e7fffffd3c88b14206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000010a4042901180106090601a611960196019e019c09a018c418440a79b7ad9b4fa77b613c90b942069001000000000000000000000000000000000000000000000000000000000000000200000000041806438048864004886488e400408e48c50040c418a418040a438a418040a418040850240a4180418064380610611041e73ffffff488c1420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000010e091e21409029063100923122900192292212039221060992390610e31a73ffffff488c94206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000099a200668841808c404310639210849a11b6019c11a0f8d418438c71cfa77b613b7ad9b490d14206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000006a384a3816a94a80a94a82a02a1062280284188a02a02a14210914210800a808a840842a02a4084286aa680a384a380a9dc18250ca12f3e6a471cd4959651e9ded8420d942069001000000000000000000000000000000000000000000000000000000000000000200000000000000026380663846006122180198488602619021068269021068071021460261021461fe094c18250a99150b2a4fa77b613a6a6a6490e14206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000028298018a600a90680641ab24a0492a0ac128600bc184388693b568f4c88c94d3ffffff4e3f0f9530306074a0e94206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000b9228164880922180e40c438a018c50443845036418462f0619032073ffffff488f142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000001861186018841a01a2120aa0906006220aa0280da800d4182388710943734f23c771342808c4ffffffd3071a104a0f94206900100000000000000000000000000000000000000000000000000000000000000040000000004a036a006a18a026702a88a1005a871009c099882801a80da8007f8cac806ccb8838c8e3001b0e498810038ca01cb883a51a5981838181aa0c182414899a14316d4c6480d931e4ba84ab050c5b53b5d3e54c2850c5b53ebd0a34d79510d30a303aa94a28c0eaa534a303aa94b58c0eaa539a303aa94e10142069001000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000066f03ee1806e9ce81ee986e80e98ee80ee1c89ae00e1c2106b803b86a06638038690918e00ee1a8198e00e1a42463803b86a0663803a61093a05ba622e84e988ba0316038607bc032a32b30609b06b306a1b06134a1b40b4a3b20b0a1b405b06b300b0ab40fb0e0b0605bbc18c61cc1cf31631504e61c0ed3ffffff4e31a4e938c7a3a4b10942069001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000001e6184e600e700e6380661468261062186459a4598098459a49a49809851a41a49a49809851a41801841980198419811860598609cc18449291cffffffd30306074911142069001000000000000000000000000000000000000000000000000000000000000000301180998079a6079852002049803a248880080841a01a85080a02128180a06128826204aa818814800661462062861062801a061262802a82803a262060470167029f062905204964fc532555ce4c25c79531039a04ffffffd3ca9194206900100000000000000000000000000000000000000000000000000000000000000026280e3016218062180e21842382402238221825003102022102804804802182302404482282282480648264816401e4846d061924a273ffffff489214206900100000000000000000000000000000000000000000000000000000000000000010000000000000000000000a03886038a0b82c18228649071a1048129420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000d88608c038a408e40a018c6018850241806501e482e2b0611031e73ffffff4893142069001000000000000000000000000000000000000000000000000000000000000000200000012a01ac07a8408a0261222803a840842866084a81288aa019aa22a00b03ea192418248a89150b2a4d0a023130306074cc1be2934a978f4a1394206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000181084006210019c00a018a09a0126d926026146026106600e680641a110c18448a81a6a6a64fa77b613150b2a4914142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000002229010a40091a48449a88081a88281a8849006902350611021c55dc6f532665ac4ffffffd3150b2a499494206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000003058103890007008438a39001098e230850b870010ba8390850b8a3b01b8c3b11830780f081708165d061163264542ca93a6a6a64e4bdbc75d314f6f1d74f33cfb31d3ffffff4f23ab653cb951420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000001a88a80a88a809a8808420aa021082801a802a8188aa8188ac0aa0a88a80a88a812a1f96418250a99150b2a4ce9360d366b0d94ccdd68533b568f4a1594206900100000000000000000000000000000000000000000000000000000000000000010000000000000000201620423822380e1f84c18238861171b2f481614206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000680e6806886046886884181182106046700670bc18430a59171b2f4fab46b5382603049169420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000418243982100902184982100902184206a00a06a0e0a06370608a2944a8803d3eae5dd4edeb66d38c672549971420690010000000000000000000000000000000000000000000000000000000000000002000000000002500e500e40c40248c404408e508e40240a40c4086408400488e508e50040c40440c400e500e50065d061143a240028453ffffff489794206900100000000000000000000000000000000000000000000000000000000000000040000000000000000000011c199851805986019848a41811a4198098488641c50a49801840a68a418488e49a40a68a41848a68a418018408649848a68a41801848a49c488641809c49a09a48a49801a0986019a49c01809801801a09a01c01a09a0180398098018098139809813d418a51aa1d7fffffd5e4cd5f5118142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000001c21a01840861221a40861221a49851c41a418118e00e418420c41cffffffd3000a1149189420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000418243982100902184982100902184206a00a06a0e0a06370608a2944a8803d3e4eed54dba50dd3394d1d4999142069001000000000000000000000000000000000000000000000000000000000000000200900b9011221a11a2120180184086046084180180180106081084180181180106044180180398079811a418440c79171b2f4cb840e13e9ded8491994206900100000000000000000000000000000000000000000000000000000000000000010000010200e408090e090e0387e170608e21845c6cbd3eec4ad489a1420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000010210210010210210010210110210110039009809a01a09801c11c011c18630a591d27424c5c6cbd3e9ded8491a9420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000218038860442003908006810818120420602880e880330610e2184542ca93ce5b8ef134a978f499b142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000068008016218800800218092620020498020e020e310608c2164542ca933a4c814fa77b613212b4a499b942069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000068008016218800800218092620020498020e020e310608c2164542ca93ffffff4fa77b613212b4a499c14206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000028062804180190624124190608a19257e874d3ffffff4c910e093150b2a499c9420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000011401940990e090e059560196e090179021023060962a64542ca91150b2a489d14206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000012039201821211821229210a439811460041a019068d418230a595e54434ffffffd3b7ad9b491d94206900100000000000000000000000000000000000000000000000000000000000000010001201921102006408090e010e1b0608c1964542ca93ffffff489e142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000060860460861008841811a21002062003a0622310608e19873150b2a4c9996b13ffffff499e9420690010000000000000000000000000000000000000000000000000000000000000001a038a108400e210118e098e1186c182388615e54434ffffffd3c91f1420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000001840a058a418018498019849811a059a089c182386712f3e6a4eab83c53150b2a491f9420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000a06826620600e8089006908602a808122220a2290600a1a22128028084a062a0aa839a83aa097418250a990306074f3150b2a4c912d49342808c4a201420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000008400e210108400700210098e098e11894182388612f3e6a4edf27b93150b2a4920942069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000028200ea0803aa2006a8813041a830a3041a831ea00c580370609021c4542ca93cffffffd330be6a4dba50dd34a978f4aa11420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000884080398282418210200e60a48260a038a600e418039a10e418440879150b2a4f3ffffff492194206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000001a039a01840860460841a49811849801a039a00c418430859071a104ffffffd34242454922142069001000000000000000000000000000000000000000000000000000000000000000300000000000000019c059c079831801983181100302b029862b02b0090631e0b1e700c20ec02c20ec82c7806c3aa0a8ec00ec28ec02c28e03a8ec006d2805aac8067f062144a873ce65294d0ac3e5317179e4c3031f93ffffff4aa294206900100000000000000000000000000000000000000000000000000000000000000020000106019401021260250848850241840848c40240c50a40240a68040a018a600418441824180694019a01c119c18a39261cc0028453ffffff49231420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000036301e31810a49a018a49821906682290692214692602612692214692602610e619066846126f80665827581e6780604e69bc18a51491cffffffd3000a114923942069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000001a0b9a408408404408408400610600e4981798480e49800dc18638a69cc0028453ffffff49241420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000e8816883e80a800680a8036218062182e2223022223026222302222302e218062184700e281628263806784679068071066191e68066391663836698267d062985ac73cf93357d3ffffff49a4942069001000000000000000000000000000000000000000000000000000000000000000200000000000000228162806218062182258225802102182210218221806218440a058a502481e480e5006482640064006550621049e73ffffff48a5142069001000000000000000000000000000000000000000000000000000000000000000200000000000036300e290018a68840241c2398e49a49964996419e419e499649ae01996018e0199609a07986013c18641281ffffff4c0028453c9259420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000009c0598e0598e1196059c621801980182198e31a49a41d6018c418258aa1c73393c3241261420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000088060a08a60288281c22002221c02002261a00a0618080089c88289c02409842003a068081848828848d829008d80685828380e838490168182890631252240028453ffffff4f3743f3f49a6942069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000300630029020440840c41824188501e503e290610c29840028453ffffff48a69420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000108680e688039021a039a21011029c11c29009029c11c29001a40861086418601228421468268050260048068268049a01a09c118e118e0a2418849289000a114ffffffd3e4cd5f49271420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000001860198e01982398018239811821831801821831811823980182398119e01ae098419a018419801a0986019860199418458e91000a114e3a83d93ffffff49279420690010000000000000000000000000000000000000000000000000000000000000003000000000024836481648164816438064380623900902382409e089e488e482488e488e482488e48960189640040864006408640440a401640a400e4826482400480640240065024380645806501641829d0631272473ffffff48a8142069001000000000000000000000000000000000000000000000000000000000000000300000000000000011c03986039831811821981182398018259809829829801829829a0906086600608661001a01068a60060c6100980980106846906006046006036600600660366049f062144a440373d53cc082c193ffffff49a894206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000028180e818481a2a012068a80081c32002070c89a88a80081a88a89a89a80081a89a89261a0020498680081072012041c8048180e81828506192422731e703f4f03bae1337f41649a914206900100000000000000000000000000000000000000000000000000000000000000020000000000012842803a842803a832812832812c420a80a1988280280ac03ac0a802c0bac013418448a89cffffffd3e8844a4f197c913e5bfa84a29942069001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000021fa403a0603a0520122520120290690a50480c522219280280c522219280280c4a421928009084a202421081808580685849582790621452473cebeee4ffffffd354417849aa1420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000002402402400e40040040164380e408e40440c40c4004086408640040c40c404408e40440043804006400400400e402402402750628c59673ffffff48aa9420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000916111e039221920122392112259427920122922190312219062106259063120105f824b0609832c73cfc93248ab1420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000011203920590290110292110219423900103102902190292259027922590279001023922590090292014310019205941187e1f9c418c4188142b0f94f3ffffff492b942069001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000002e418165044086400640c402408e402408e4896402408e489640240c408488640840440c40240864844384418043804004044804044024804006400480e40240064024049d062945a273ffffff48ab942069001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000009a059a0198018498019849811a4198098419801c428498298428498218098498019849803a89280a881a801a8e0a9611c418450e89cf3994a532020c94ffffffd317179e4a2c1420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000198601986079829a11a408601e608518098508601621468261421805884886826102102180588488682688408680e608498019a41809a01a0186039a01a09809a018079a0981180980d9803980180f98079817b1418c518a1cdd0fcfd3ffffff492c9420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000011a21811c039c29809a21c09a31a09a318631c09c219a609a601a51809851c09a51809851a019a41a11841c01986039c099a09a0d9a019a03a1418a49689cffffffd36e9437492d142069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000501e500508400e4884780e4380408480e408482408480e408484481e482450611031e73ffffff48ad94206900100000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000ac00000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000b600000000000000000000000000000000000000000000000000000000000000bc00000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000c400000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000d800000000000000000000000000000000000000000000000000000000000000de00000000000000000000000000000000000000000000000000000000000000e400000000000000000000000000000000000000000000000000000000000000ea00000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000f400000000000000000000000000000000000000000000000000000000000000f8000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001080000000000000000000000000000000000000000000000000000000000000116000000000000000000000000000000000000000000000000000000000000011c00000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000126000000000000000000000000000000000000000000000000000000000000012a0000000000000000000000000000000000000000000000000000000000000132000000000000000000000000000000000000000000000000000000000000013e000000000000000000000000000000000000000000000000000000000000014800000000000000000000000000000000000000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000158000000000000000000000000000000000000000000000000000000000000015c00000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000166000000000000000000000000000000000000000000000000000000000000016a000000000000000000000000000000000000000000000000000000000000016e00000000000000000000000000000000000000000000000000000000000001720000000000000000000000000000000000000000000000000000000000000176000000000000000000000000000000000000000000000000000000000000017a00000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000000000000000000000000000000000184000000000000000000000000000000000000000000000000000000000000018a000000000000000000000000000000000000000000000000000000000000018e0000000000000000000000000000000000000000000000000000000000000196000000000000000000000000000000000000000000000000000000000000019a000000000000000000000000000000000000000000000000000000000000019e00000000000000000000000000000000000000000000000000000000000001a600000000000000000000000000000000000000000000000000000000000001b000000000000000000000000000000000000000000000000000000000000001b600000000000000000000000000000000000000000000000000000000000001bc00000000000000000000000000000000000000000000000000000000000001c400000000000000000000000000000000000000000000000000000000000001d400000000000000000000000000000000000000000000000000000000000001fa0000000000000000000000000000000000000000000000000000000000000208000000000000000000000000000000000000000000000000000000000000021600000000000000000000000000000000000000000000000000000000000002280000000000000000000000000000000000000000000000000000000000000232000000000000000000000000000000000000000000000000000000000000023a00000000000000000000000000000000000000000000000000000000000002420000000000000000000000000000000000000000000000000000000000000248000000000000000000000000000000000000000000000000000000000000024e000000000000000000000000000000000000000000000000000000000000025200000000000000000000000000000000000000000000000000000000000002580000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000026600000000000000000000000000000000000000000000000000000000000002800000000000000000000000000000000000000000000000000000000000000294000000000000000000000000000000000000000000000000000000000000029c00000000000000000000000000000000000000000000000000000000000002ac00000000000000000000000000000000000000000000000000000000000002b400000000000000000000000000000000000000000000000000000000000002b800000000000000000000000000000000000000000000000000000000000002bc00000000000000000000000000000000000000000000000000000000000002c400000000000000000000000000000000000000000000000000000000000002cc00000000000000000000000000000000000000000000000000000000000002d000000000000000000000000000000000000000000000000000000000000002dc00000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000002e600000000000000000000000000000000000000000000000000000000000002ea00000000000000000000000000000000000000000000000000000000000002ee00000000000000000000000000000000000000000000000000000000000002f400000000000000000000000000000000000000000000000000000000000002fa00000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000306000000000000000000000000000000000000000000000000000000000000000050000000000001ef056e20a20e046238a20f00643801baa20e00e180e806638a20e006e3852a8c3813d9048e05744944013d36c211d12516c00fd12d12420fc9651251204744954811d12594490047459485f25415d92d817d1285f259485f259405700125019d1206765015d0051606f4580fbec1a823291b7ad9b6fa77b61bffffff6f1b1b19becbcf9a9b3a4d836c84ad29ad4ec749d09b0ced012420690010000000000000000000000000000000000000000000000000000000000000001001850240a518518004c18220630a0ba7bd734792ea0d562da93101a42069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000002100198210a02c18210c00c98828c00c1802b0608628c6d0cb430c8cab0da37eed34a05140d562da9328224206900100000000000000000000000000000000000000000000000000000000000000020000000000000000059c0d9a41a099a5180998419a059a49a21809a01a41c09a01a0186039960b9c0f980181394418a39471171b2f37fffffcdb102a42069001000000000000000000000000000000000000000000000000000000000000000100000000000000240240c400500110608618a73afbb8d562da930832420690010000000000000000000000000000000000000000000000000000000000000001000000188e038a10a10a038a00a05880880b8a0b89418830c59b003a42069001000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000004a38364286ac0ba868ca02ea1a088a826a1a08aa026b0422a0598a184b00ea19001ac8826b807a86804e4007ac01b90056e3015b10056e4013b9004ee856e4015b815c0c05703015b215b0e056c3815b0e056c85703815c0e857085f005f004ed106a06f207a77b61bb7ad9b6ffffffdb171b2f6e6b0fb8decf0a115b212b4a6b842420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000001fa460081217a2022620613a2120620022038c03a00980206220200188e0a40a46008008900a2021611881803a16020e6046900e882e7b0619c43045c6cbd72f3e6a5f71e4ba83184a4206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000004700ea384a00ea00110608a19250ac3e4d562da934d67fd0da37eed344a2bacd2593f132852420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000300300810800800800620600e8028008802b062064086d171b2f368dfbb4d562da93185a4206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000080990282628062044080902006488400250608a29245c6cbcd1d274230862420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000044180e408640440964006026606c1842885120404634912918dffffff3106a420690010000000000000000000000000000000000000000000000000000000000000001000000000000094110310012112130608818e458c540d26268530872420690010000000000000000000000000000000000000000000000000000000000000001000000000042380e284284280e280281e286c18430859535bbd3007a4206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000006628e0d9890ca026622b0aa82ea10a10a0aa81ea12a12a22a816a12a12a24a00eaba4a04a81eaa2a026836aa0a05ea866a866a1dc18a51889b50ac3e4d03060737fffffcd359ff43208242069001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000005a1e13a06b83681b6099266780e40a691a81a1102b9c91a1102b98681c88040ae6ba2010299a681880040a66da0010299a6882407e6f0621662a6d42b0f937742b0f95988a4206900100000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000006687668266866682e705e6836685e682e7056702e7056702e7056702e6184661826638466381e638366781e6582e678166886381e6981660a63816638a700660c6784678a68468c6990e638870260c679471470a68260c65926792708618c67916619070a70c6392059269261221c298e403641a5182186218e403641849c218629864036418e298098298e4026418e318099e0926099e039c19986150c18a7b2e91039a04713c3ca94109242069001000000000000000000000000000000000000000000000000000000000000000200000000000062f8163580e378421806204218430423822182304238430221843042180282300e3022002842b84306e286e286e218c18851899b009a420690010000000000000000000000000000000000000000000000000000000000000001006382608608600694685c1822063926268535e97ac8dffffff310a24206900100000000000000000000000000000000000000000000000000000000000000020000000000000001e404e5046501e48450448041804380438248164025024022044004806400300481e500502650050065d0611051e6d7a5eb2308aa42069001000000000000000000000000000000000000000000000000000000000000000100000000042380630428020020162581e206c184308591324e0300b24206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000002413a02226a00e808804b20b04818802a80ea82c3812809a80b8c056e3013ba13ba15b817b817ba1597419031881fafafa6ed2d2d1b1e4ba8342480e9b9ac3ee6c2480e9b128aeb6b0ba42069001000000000000000000000000000000000000000000000000000000000000000500000000000005b6e07b0b9b003b0ada2a3b001b2a1b0232aa4a1b001b0a1b021b0a24a1b001b0b322198c29ec04c22ab065b0a7b01308a8c10612732a24a30130b304984986c28928c04c2cc79cc28928c02c22d2ac598c286c04c22ab4a3b4a30ab0130a34adb4ab0132a5b4b32a00ab00b0a3b2029603a8c02c2ad00eb01ec031f063188306d36f2fb352a5e3cd0d0d6a37fffffcd8ea0f6328c2420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000e83876818688668196905e81986885e88880889a805e88a4246a017a0214918885680841a072001a209a25227220a0623e52272066fa2672002061fe80289ae879a884899e801e900e8986906685856ad062128307536f2fb558d5f6551414a1518ca4206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000001415940920120f9160120920b92019201209210c0120590092090e010601900100790661403940d980181f981180b9a4184610b93a4d83345b43e8d265d87310d2420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000002413a060a20220f90838088250264221220220a0482312880e8028828148008108806800801e81a889803a40da80281fa81280b9e4184610b93a4d8334792ea0d2882f134910e08d265d87320da4206900100000000000000000000000000000000000000000000000000000000000000010004258062002806300200281e280203e208c18438869171b2f300e2420690010000000000000000000000000000000000000000000000000000000000000001000000000024043004380400400150600620a558b6a4d281450308ea420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000003a0e0ba240842205a2508522122418841a20a06fa0026613a0370611039e45c6cbcd1a1a8534a4a71cd262685318f2420690010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000223822b81c18228449244382300fa42069001000000000000000000000000000000000000000000000000000000000000000100000001c01031260861001c006418218829b4749d08d562da93110242069001000000000000000000000000000000000000000000000000000000000000000165016408e4044084780481e50361d0610c29668dfbb4d8668c43090a420690010000000000000000000000000000000000000000000000000000000000000001000000000002302484480480480150608818e4910e08d262685309124206900100000000000000000000000000000000000000000000000000000000000000010000000000000a08c08a00a038a10c00c086c18230659150b2a3011a4206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000660849801aa801e82a028818081a812c12c12a07aa00cc18438a693c658534bcf9a8d7a5eb234b439b0d2626853211a4206900100000000000000000000000000000000000000000000000000000000000000010000000000000022384284280280e301e205c184288490d1bb63012a42069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001106059229411223920902790609901f0610c2964989a14dffffff30932420690010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000805880096002c182284411d27423013a42069001000000000000000000000000000000000000000000000000000000000000000300000000000000005986179a41c1398518e0d9a41a60b98498118e07986079a40166106022184610600e61068a08a01c41811849ce41809841841a0598419641860b99641817980981da4418859aa1e9ded837fffffcd7a5eb2311424206900100000000000000000000000000000000000000000000000000000000000000010000000000000000000000c010e070608610a4542ca8d2626853094a420690010000000000000000000000000000000000000000000000000000000000000001000000010a03886018861096089600c08c0f8a0f88418221241b0152420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000002e4186e498564d84651836578264380e4581641826458064382e438064184238443824184e4b85e4985e49866500486e480550621872e4910e08db095a420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000118e49a41c401e6990712079c41841c41a41a039c418e49a41a0398e41ae400e61906b9061011a418603996400712682669401c41a0d98641841c108e019841841a4181598418e159c01a199a0181b980981b980981fb041905a0a9ffffff37a77b60db11624206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000392e0994e0390e0390e11060b9060940f940920188e0190e17906179419941b921b903f062145a6484ad28db096a4206900100000000000000000000000000000000000000000000000000000000000000022890088e09088481c0ba460081c0fa2600898119881a8181598818885e8185e6221ba21ba21b9880765d065145a6484ad28d2f3e6a34910e08db19724206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000001e705e658467146836612619260266106792601677806739068263826690602703e6180704238066584e658566185e706e618c18851c9942cff9345bc3f0db117a4206900100000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000170c87003f0ca94a0ba884a740848802704a6a86a92c007ca42a628610849001704861062862a62b0806a41221018a1902841901108504a81842862d1110050188c2a98aa0642a030a3082a192288c40c0840800c00331280840c03021280c10ec4a621030021029330f3188b002104bea4a840c2104cc00ec29281240c41284e80e833010ca03b803803cb04a17c8619ca1dc81ddcc18c52a9923426434389908d150b2a351a070cd3b568f34f9ba8cd2665ac34989a14d3c3ca934182420690010000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000001603404a01f600f4036856014016036016816500280296180ab4580d86d0a5865a058ad2ad1601751650a5805865002b4580296196516297016a8652a53681655618058628029429600a58658650a5a601458a194d8a516816d0658601619618a58ad0a5065b42805865d429601629703650658a51619618a58651629458a536286d16516296006582581594194a94196194194d8a5165362a6537294996196836994a94296194594d8a51619458a5065955b498251605654a5945b4195594a9419b4595594d82296007650658a51653699458653653619499529619651600f65362b6114d94196556516d0651650a58a5955805d95296d066516516516d06d2b54e5807da852a5941149969965162941943a950160276994a96d36d1653629459418a516d1619682f6214194294114586500594296516194296d265a0fd952b6214594d9429651618a51652651604f650658a58858a5945865a65942945945865a13d9419650a5365085b4594594d94996396057652ad16516206214594594d8a58639605f6a9629558819650eb50e5819d16296516d16216d0051601629651606f458a5945a05a0580586a516516067651650a51700c18161d1651606765163945a05d0d8605945945819d941d815b258601d94581bdb45801c8605d94da17dd45801c80fd16867651606f70676877651606f407f68761fd809814201929bf3996fcff350b3fe4d2f3e6a36df27b8d42b0f934989a14d3375a1357e874cd2d66a6349996b0d38b2d73518a4206900100000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000007e806e1fa21987e8185e1fa2c201787e8b080561fa4c221387e930884e1fa2d201387e83488461fa4c20c221fa8602e83081b088267016a1826904901ea584a82a81e801e800ea184a02a806a826294039aa816a00a016a1c139ca81eb01ea986a1803986b04b02a82a184a39aa806a8e03a801aa0a80a805a8e12c09aa0a8601a80787ea182b00a85e1fac1387f29063a4acc4bcf9a8d1d274246dc4549134d060b173299242069001000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000017ace0b87ebd8161fa8ecda96107eb34230e2b06a3821faac88c18cc18acac087ea30e2bb4232a821fa8d0d6c1a8087ea3239b4a021fa8c0c08a608cc2a107ea0a01896038aa001f90690078860792604401e49801062049c090882e70049881849888041a4188128128808920a2418291849801849a0146204008980188848848900909029046220906200d04188b9d613758a034790230d28145034dd6281b1e408c6ca05141b3c5a9b3319a4206900100000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000003a812801a811a842c42a0284280a807a8290a18498a184a862807a829a649ca016a18479c41889803a82106619460892812a4198e5182a4a02a084198e42870a8a8088439851aa1c2a4a88418518a126aa68a92a45a851ca1a2a4a94690a1066a870892a5184a8419aa10724a946284284398a10628624a9462847a8498a1892c498a106a192a98928028498a11ea90a1a92802849a028641aa60892802849aa82b10a9a222a02a0a42a03a8428724a00e62807aa122a816a026a00682807a80187ea0061fa817f8418c632b9b7a30ebcdeee9e637fffffcdf1d9cc321a24206900100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000e81881803a262003a262003a262203a06a005a0608800e898220600680880881801a07221226206088180a0218688289881c8180a062061a00a2658281c41c80081a51a802818e8006800884b90610a9147a77b60dffffff34989a14ddcd2c8319aa4206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000002e6181e638460c704610e638867024998e29a11a4999601984f986019a4186419801a039c11c11981d9a1d9c0996c18a31699000a113470c540d1414e5311b2420690010000000000000000000000000000000000000000000000000000000000000003000000002e4186640c485e4086482e4588e43806418e48c51c402419e48849960106b9467926d9069926b9467926791665926592663900106392e7100906392e69001906391e690059060761fa4c18c520a942b0f94716357d9411ba42069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000001e482e408481648c4016408648064096400538b6402409e40064886401e4184410618a5186d36f2fb309c242069001000000000000000000000000000000000000000000000000000000000000000200000000000000005920f902900992219205900920901f9811211802060080240240481811805988024f0620e41c63a83d8d1414e536dffffff319ca42069001000000000000000000000000000000000000000000000000000000000000000108138c098c00800a098800810c018c008038961f8b418240c79b01d242069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000400e401e484484488090e03884046210012099021229007884080102836450621439c4002844d42b0f9309da42069001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000266183e6886682660a66016678c600669267006006146700539809853846146039a4b80e6391605996119c1395c18c39a89000a11350ac3e4d1c3150311e242069001000000000000000000000000000000000000000000000000000000000000000200000022f816292e280e213e284214e28221229362802123136200212214e2916212e290e312600845884982e206e2036610621262450ac3e55d09ea42069001000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000019aa61587ea34a306b0361fb0ea31ea30a00e1fa96caac7a8c28107eb3082acaaca8ca2ab0a001fb2a20caaca8c5a882cc281db48b2ab4a30a306b30832a066d20d28c1a8c5a8c28c28ca817a8c1a8c3a8c28c5a8c7a815a8ca8c7a8c1a8d28c1a8c20c2813b4a31ea306a336830a83ea34ab06a32a356a20c280fa8c1a8c7aad28c5a8caac280fa8d3a8d28cda0c280fa88346a34a33682a0fa88366a30ea30ea04ea32edf856ab36a18623268781e85b26a1962316a7a203a0c7a0c58863067306ab1e884832e8b066b0e6b4a33e40283368b06628e630b316430430a34020c28c10d28d20c3a8ca96c1a842801b06a32a30092ca8c788634b306a10a80e432a30400e4b2ab4a0861b16a12c28c016d2807b04b4a886388a190a32a320590c28c2807b2528019e12a030aa007b4030a0566581e881642a4300b04001f87e02c6062aced67fffffcdfcdbcb364793a0d42b0f936deb66cd128aeb329f242069001000000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000003ee1a80187ea3cab8e1fa8e9aaf06ef785ee1a8f1a811a8e28e5a8ed83ee5aae28f28e1a8e82eea8e1aae3a8e2aea8e2807baa38eab8a3ca38abaa1816ea8ea8eaae28f28e2ce28f2801bca3aab8ab8abaa38b38a38a38a006f28eaae2ae2aea8e2ceaae28e04f28eaae2ae2ce286eacea813aab8a5b8a9bab3aa04eaae296e29eeacf006eacbfbc03b8b3861a8ef1ab3c05baabc6bba6aaf01ee39261261261261062af026e390612612612638a1ba13801bc61b8e63a86e84e180e7982b463ae03a03c03a93a2316aa06e382e5a0ec7a1ee184e3a16c3a26e382e3a7ef00ee1a7ef02e1fb8018081818c7b8f9b50ac3e4d34202234d080887000a1137fffffcd128aeb331fa4206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000006a10a10a01ea08620a10600ea08a30e30a10a04a08630f30a20600a10630e3b0a20a04c38ec01f03d002f100e6d0620e41a63753c8d42b0f9349996b0db4a0a0a0d000a1134f0f0f0d32323233a0242069001000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000baa0387eb0061fa96007eab876af85eaf90a846b590a82ea592a390a92a026a394a590a92a80ea190a794a90a10b006ab90a92a10a94b02a190a392a906a92b00b390a906a90a990a10b790a790b790a90a790b990a90a590bf90a592a990eb14b00a90a10b794b00a190a89e028e4a8602865026af82b12a2fe0ac42abf84aa06a206a3a06a184aa06a20eaa16b006b24aa46b00eaa6e42805aa9ba809a899aa09a899a80b87e1f87e1fd941946c2d91c31503470c540766a0d934ed5a3cd000a113220a420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000388e07886438a0188508458a108418845881085384214e108418c4582212292219408c40c50a0188088508488401e2126098a40041846505e4827f0629072050ac3e4d000a1130a12420690010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000002380418210229b021a42069001000000000000000000000000000000000000000000000000000000000000000100000000000000000008a098c00a088058a0188006418618e29b0222420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000001e8b8368f82e82a69026a0aa0aa08aa407a82a82a82aa88066f88a08a2201a4d98a1a2614e8580611e69485826106690e8584612610e119841851a179c0da1c18c41aa1b50ac3e4db50ac3e4dffffff3222a420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000e41a4182641821986400e688608661901182b98610c669001823a8e31a01827a82199625a821986010608ea0c6180641aa39a0da2b04e82a079dc18a49889010a053400200cd3a3f3b36d52595432232420690010000000000000000000000000000000000000000000000000000000000000001000000000000000000000008a008038c138c008105418818e29b023a42069001000000000000000000000000000000000000000000000000000000000000000517940f90607902900b90310079229007903100b9031003903100f9031011021900f9021900902190119031009021900390059021900102190010090210090090239221922123122100102392219031031031223922190291e3102390010310605906239001021900f923101102120900590112210019409009009009011403900190059003901190012010007e402403f470639a9b26dccf2f430a42420690010000000000000000000000000000000000000000000000000000000000000001000000000000000000201e3003003380300301e206418428a49b024a42069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000501e212018c48421916310112290019221029062083906dffffff30a524206900100000000000000000000000000000000000000000000000000000000000000010000000000000000000000b8a07886038a089e1184418230a51b025a420690010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000280201418208411b026242069001000000000000000000000000000000000000000000000000000000000000000200000000002647836409e402640ae401640be400640c640440ce400558a48c640a40240d640440c6400e40ae481e4b80e590618e6246d3375a130a6a4206900100000000000000000000000000000000000000000000000000000000000000020166180665886086806116688608600611e688602691e680614690e0184598484611e059845816690e0798e0597c18e21669b50ac3e4dffffff312724206900100000000000000000000000000000000000000000000000000000000000000020000000000000000e90269089006910310902818279880081a41a81a41a9783e800e800802e80480064d0620e49a6d8668c437fffffcda3bcf131a7a4206900100000000000000000000000000000000000000000000000000000000000000020000000000002e409e11902b83e40b60b92e2181650a648a40248d6500409e48ae489e409607943102584650a4076483e550628e5aa7542b0f950a82420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000026885e80a804e88a884680868026604810680460462c802882800a98098b02eb1ab0068806b180aa120601aa019c188492910344eb36d0c0c7e3619a310d5e03eb3228a420690010000000000000000000000000000000000000000000000000000000000000028000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000005a0000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000006c0000000000000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000007c0000000000000000000000000000000000000000000000000000000000000088000000000000000000000000000000000000000000000000000000000000009400000000000000000000000000000000000000000000000000000000000000a200000000000000000000000000000000000000000000000000000000000000a800000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000bc00000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000d600000000000000000000000000000000000000000000000000000000000000ee00000000000000000000000000000000000000000000000000000000000000f800000000000000000000000000000000000000000000000000000000000001060000000000000000000000000000000000000000000000000000000000000112000000000000000000000000000000000000000000000000000000000000011c000000000000000000000000000000000000000000000000000000000000012a00000000000000000000000000000000000000000000000000000000000001320000000000000000000000000000000000000000000000000000000000000140000000000000000000000000000000000000000000000000000000000000015000000000000000000000000000000000000000000000000000000000000001580000000000000000000000000000000000000000000000000000000000000166000000000000000000000000000000000000000000000000000000000000017a000000000000000000000000000000000000000000000000000000000000018c000000000000000000000000000000000000000000000000000000000000019600000000000000000000000000000000000000000000000000000000000001aa00000000000000000000000000000000000000000000000000000000000001be00000000000000000000000000000000000000000000000000000000000001e400000000000000000000000000000000000000000000000000000000000001ea00000000000000000000000000000000000000000000000000000000000002020000000000000000000000000000000000000000000000000000000000000210000000000000000000000000000000000000000000000000000000000000021600000000000000000000000000000000000000000000000000000000000002200000000000000000000000000000000000000000000000000000000000000232000000000000000000000000000000000000000000000000000000000000023a0000000000000000000000000000000000000000000000000000000000000244000000000000000000000000000000000000000000000000000000000000024c00000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000187e20161f88108007e2842001f88018a0081b88018a008198a018a008198c10960080d8800c00b6098800e610801896018a600800a08a608800a3f84218fe058ee08c038ee098a00c00a00800a1080988078801880bae418c722d1b80134206900100000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000005e298007e218007e218058a118a6006285661001886056212092210139a48040a1590694610159841a498179a21a418179841841841a1798641a15886190704e21864184180f98019e41a01070060261886107107106106f90018e41a41c6099e41c6098e49ce019ee079d60b9c6119a605bed0b0f90630b116f0fc3e5bf3fcf42cff93901b42069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000620362022016282280e2022002006282200282284202200284204290c18c28e59b8023420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000001081b88088617880086198c00a1988088e118800810c138be00800808800800c058a008600860080080389e008600a038c600c018f6018a08a08a10a008098a08c08a0d8a08a15a7418e59cb142cff93802b42069001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000007640764866501e40265016408401e41806508400e4804084024388404502408498843844884f88400648a4988481640a458840364581e75062946266f3c3c3c38833420690010000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000107e4380e418664382458664580458665186e5186e5186e4f87e4d87e4d87e4380418764382418764384507641806507e290038a1f8c018c1f9028062901d9405941990605906179060590615906079160f90e079160d91609916099160d916079160f90e0590e1590e019161794e1b93e007e4783ecb0629eeba50b3fe4f212b4a3883b4206900100000000000000000000000000000000000000000000000000000000000000050000000003921590202e4881590281e5081590281e5081590300e50a15902920192305640a50250c158c418050c158c418050c15886478c15886478c15886478c15886458861588645886404640c498c404640c418091c959c902919e91ae818491a681b6880e89a681ae900e919e81ae881e919681a6882e918681986903e9985683828182f070649ec3845c6cbcf212b4a3c5c6cbc7212b4a198434206900100000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000070061f9c0387e6887021f8861841f9841a107e6106841f9841a107e6106841f9841a107e6106841f9a4841f9c40061f9a40061f9a40061f9a40061f9a40061f9a40061f9a40061f9a4066700e6101b9a0398400604e600680e6182e6006580e700681e6026007016680604600602602600681e61826806026026182669201809a09841c0b9a418609801a41a0f9d6159ae07d041885bad12f3e6a3ce9360cf171b2f3904b42069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000a1b886178a6118c60988e08ae0189610b6088e018be008e058d6098c60d8ae1788e078ec18c596a9212b4a380534206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000010199009019900921592010611926119261194200503e418801060d9060885036508110e078848803942016214200e214210110e20162136202e2942122016870629472869a9a98f6a6a693885b4206900100000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000002c22811aa622811aa622811aae2046ab8811aae2046a188aafe22abf88aafe22abf88aafe22abf88b7afebfafebfafec2eec3aeed00cadec180c1a0b1b060348b062b6c182c24d18a7b061308b16a5b0601a0cbaac580ecb90c581ecb90c182ecb90c846c582ec906298eac4910e08f2443821e5b8ef0f128aeb3ced5a3cf3b568f3a863420690010000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000a089e0f88e00800a009600860f8800a600a600a0f89600a08be0f89600a08a00a60f880096038a611880096008018c00a13880096008018961389e00a109e158800860080388e1788e00a05886198a00c078c1b88e058800c1b886108108e1b88600a038800a1d88e108018a1d88e10c08a1d8860080188e1d88e078c1d8860b8a1b886038a10a0b900390010e0189e09920192011e0190e112110092010010601921116090110090090014059003906092015601900390e5f82e5f8450264005b80e48065025d80e481e482482418048448064036482480400402484484481e504402402401e40064066404404ff1064250c245c6cbcf171b2f1886b42069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000041f8a08c1b88600c1b8ae178b617886008e17886088e138860188613886038c138c1787e1f90c182696c96a6a693807342069001000000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000418261f9000801220664986202400418a159000851a0902106285640048869020269417900084084182418438819922121106004804081b9062024182102902066290e01a480210198a40840021801840850a178801229a0106906205e2390e600610210205e311661941b8848841984004186e21066906100106285e239864788158801421c01c488405628040a488600612310158c4084826006004388158a488402600610e210138c419a09840841a010138800849c11a41864080f8c01271009063804080d91e21061009c4582e210200290660461061221001220264084188498118418010680210200e219071461001926886084b8851964016418e40a5002906192610010059068841a21840840c694610600402e638061880106926006900f9ae11065901798e05980f80b0818c8c1012665ac3c84ad28f2443823907b420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000461f881080987e28428161f8a038a107e304282304204e21816259200a10a08a010258162590298021902981631233902382621942f80488e058c01201000a6114088610a0590108603900121086a54482e3245c27fffffcf16f0fc3888342069001000000000000000000000000000000000000000000000000000000000000000600000000016486e1f9020361f90039028261f940390306e500e41808190214159421011421289a814210609942190092310020619423941122590623900206191621920902390e239202063903143100903142b901206192219421262b94122720409650a48be500e89a81230fe501e89889220fe503681943b9213a0e50be43856818839431261ba0620e094312087e8988180650a4187e81889880164b86e89a88561fa26200787f610662aacc55105e0f7a5eb23ef1631503988b420690010000000000000000000000000000000000000000000000000000000000000005000000000000660461f9809984180d87e610601e41980787e614600e610e60061f9845980191e600485e4806126602611e6004182e459a4798418012e21160591e2916602690691629160191e291e01906026116211e111e6084598019811843980184780479801843980d984198098519a11841980d9a51811c479a05985046612601e6782e704e68561fc5d160b8ab1d51bcc317acf82603039093420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000006e6081d98201645806498202813609468802059982008166608018599820061666080185b88015661081201566008900184b9848081002449845808184008101206108128184028900a01206008180a0604801e804804805e805ed94286e5148a84dd930492593f1250ac3e491e4ba82189b420690010000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000a180a1806b1a0186a0ab0a600660ca1a21a0282a832860262821982980982a821aa0182398218019827980182798039825ac2598079825a825980b9a2d980f98649cb180b9a818839881a860166a26a4720ea0066a46006180620ea046a06a016a20ea04620ea016a20ea04620ea016a20ea04a20ea016a20662812a92809a88aa03aa82a0b9882807ac0daa01ce50c2f9e626b9bc0d13acf0306073c100c1cf2593f13a0a34206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000d941390210604640a604649811a211a00a20fa20a0e09a417a417a41b87e800804e8028046880903e88288165f06320820531214cf128aeb3d0ac3e4f071a10398ab420690010000000000000000000000000000000000000000000000000000000000000006000000000000000d981387e684e1f9820fe119a20fe4280d984083f90a02e6143f90a0266106a0ee4a8079a52a25922b92a016694a92a8a4389651805984a0a106a12a10682842a428518039852252a8aa52a4284a8518019841a442a4224284aa4a88aa498019841a441a04ba881941184197e819460065abe4ba45180289995e600aba26b1c4d980ba9e87aa710e605ea3a266587ea3a266280387ea1a4a8361fa860d4511139a72d11bd2a5e3cf000a113cdbcbecf36bac31a0b3420690010000000000000000000000000000000000000000000000000000000000000007001b98e107e60866386e689e6076609668766096607e6096607e68866801f982198107e60a60061f9a2180387e608600e1f982180387e608600e1f982180387e60860061f9a218107e68a6041f8866041f8c681e60811886602660a0f8c68266880f8c603660c098c681688260ce681681088068be681e81288060ae7026814898279c4a205a0439ae43a205a05fa005a055a043a005a245a241a043a009a241a041a243a00da0e52202041a011a241a00a24a013a041a2120611a041a2007e8148841fa04220387e8867a74388e89d3b66fa439cf5cf1414e5218bb420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000007e6185e678466906783661261806181e690638469886906380e69061886781e7106886190602e6b90603e6b8666001f9861b9809a159c11a1398119dd0d079459ea9bcc8c8c8f42b0f9390c342069001000000000000000000000000000000000000000000000000000000000000000600000000000000001d87e1f87e1fa0e007e89a8801fa26a0087e81a8021fa07021fa0707688081c1fa4707e9088181fa06202981fa06202981da2624607681c89812015a0720682904e818e80081846819680081888468196912883e819689069026898e9128928180689968008128184188128798e8808128126a062066a063a00a243a061a072061a212241a06106a061a06a205a24a049a8186818368798e886e878175b4202e39af324002844f1c31503cc4e598f66a0d9398cb4206900100000000000000000000000000000000000000000000000000000000000000090000000000000000000000005e1fb06b03e885e902d2c05a8c580885e81a832a982a31ea18885e81a420a02b00a82a32a00a1262019a442412a12861204a81ba866a20a80aa02a0206a0b066a1a062203a80a80a0620ab0a066a180884e800ab0a06ec801fb2a066c386ea30a866d28c06eca81db4a3017a8caa3bb4a3017a8caa3db2a3017a8caa3db2a3017a8caa3db2a3017aac2a3da8d05eab0a8aec89ed066a32b09ed09ec28c06ed2a25b425a8ca81db0a30b086ca8c0ca7876ca8621b0a8ab34a30007ec2962b0a0aab4ab2007eca96c28eca86c041fb2a3b0a1b2a1b20187ecaa6c296c0161fb0b5b20587ed2b6d02e1fb4a00caad281987ec186e021c45c3e3aaf544505284f1414e53f93357cfbffffffcf7272f31a8d34206900100000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000041f98e0d87e692603e1f9849a087e2b946041f8b6498107e2d906b85e2d92e704e2d91e6384e2d9066186e2d946801f8b651a007e2d906687e2d90e68762d91670662b936618462994e604e299066b81e680e2790e68566102d926604e6142992e60466145f980d9851a4f9845980b984980984598419a4598079841a118439a419c4398079a01984398018419801c4198059803984198098419a098649a0d9841980984398039960b9a49801984198087e610600e61066021f9c039a51a087e601e694603e1f9a4981387e70561f9a13e8d172b9eac519bf93357cfe4cd5f190db42069001000000000000000000000000000000000000000000000000000000000000000400000007e1f87e678a1599e80a1399e8881399e88a1199e9081199e9081199e9081199e9081199e9281199e9281199681a81199681a81198e83a81198e83a82200d98683aa818266226a00827ea02a276a849baa01a895ac05a891aa0bac85ac13aa60daf5110f8e732b9000a113ced5a3cf3b568f1d9a8364fba0e34206900100000000000000000000000000000000000000000000000000000000000000090002e1fa21b87e818885e1fa26a01587e89c883e1fa265a00d87e899e80261fa469a00587e91b680161fa06fa20587e2206da00587e3206ba00587e32069a20587e21a067a00787e21a065a20787e2a267a00987e919e88261fa069a20b87e819e88268186e81968182839c801e8181681ae81996881e81a801681f6881691c800681f6880681996819a681ae880e8187fa467a205a07fa04a063a409a079a241a06a40ba0675a043a060da24a275a241a011a041a077a0642011a0520677a060fa24240a475a013a0607a066da00987e81b6802e1fa06ba20987e89ae88261fa26ba00b87e89ae802e1fa269a00d87e89a680361fa467a00f87e918e903e1fa463a21187e87817fd474eea3b5ce6fe16e5b3d0ac3e4f42b0f9218eb420690010000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000002a066a806a06e82801a8806682801a8885e8a812a17a0a20a04a9088891ac01a8425662a01aa42881aa879aa006a12624620a24620662801aa418a2462889c918a84aa0628918aa46288988281284206a46a891a89aa04a24628918a206628898a02aa4628918a206628898a80a10918a246a8918aa06a80284246288198a246a8898a00a12898a2066288198a22620a00aa26288198a2066288988280aa818a2066288198aa06a812a8288198a2066a8898a00eaa06628819aa2262805ac898a2066a8898a026b18a20662a81aa036b20662889882811ac898a2262a15a868ac1ba8e100899091ba86b6c1000a113e0bbbd0f4abbeb3d9a8364f36f2fb3a0f3420690010000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000015d8659003e1f87f618e3bda69801fd8658f7699761a1bc361963dda41b6187685701d61d61a3fda45869075a11da65865841b61a3fc1639909b68376987698e3fc37107586dc07da6d869d83fc363997700f0586da419698760ff0d9664075b05815c641619b61d60ff0db6658615a6d8e7586d83dc07758369b05c65c65d00f701d8e75960c1679b65c239c17639b641638174164361d6996c239c176c169b64163816c0f61d6c174235c0e4436416c065915905805b03da6db05d018c709dd05864164365c0f63c3641e2bc376916406d90d9703d871189f0bd845a45909b6236196016428c3745ef43e45845865901d0217016428c0841645643eeb0ec3f6116416436196216c005b12517bacb8c43f61905b0216408416856408408408c4ef30eb10bd905870211217056a30230230fbacbac45e8c285c03da8c0940842ee30e3183ac41f641e842858605da8c0840941f8b3460e50c4164076c1e8408406d809da8c08429406060c50c5183943115a07619603762070be0c1d183943311a06a5a11d881c1e060c394614634b107d9120f704f72503e0cb94614634b3159059121623706772501e0c3b4614e1531840e85882961801fd970e0c394e0e50e614b2e456780e1fd978315634e34b2e41658361fd8741e141e1561258e1387f6e47561687e1fe5e007e04664742e8bb1ee785b96cf4abbeb3f93357cf6e94373e4793a0fff9b633ff36f2cf36f2fb3ffffffcf66a0d93e6b0fb8f9ac3ee1d8fb4206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000f88e00a6018e6088600de10ce058b60d886058850b0b8a48e891c31503810342069001000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000000001d9a1787e1f98e0d9c1b87e678466183e1f9b6559960787e6f9566b8261f996579b60787e6396671841f99e5b99e107e6f96e6987e7396e6d85e7796e7185e7396e75801f9965b99e11961b99e5198419a60198e179a64598439a51ae107e6b90e690e6926f801f9b6419a459c41ce1999e29c51c4398641de1399e298651c51841be21ae0b99e2199641c51849be29ae0b9a239ce51841b6259a6159d649849be279ae0d9ae21c7f8a66b81e6b8868871fe2f98e039a631a29fe01c2798e039ae29a01831fe01b6079a6219a09a239ee118e0998e23986019a259ee199a60b9c299c601a1587e658866f82618661f9c29c6019c1b87e60873816685e1f9829ce0187e1f9829ce0187e1f9831c60187e1f9a29c60187e1f9a31be0387e1f9c219ae0387e1f986239960587e1f9d60f87e1f9b60808c01a9053c9be75959593910b42069001000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000041f9060987e3100987e3100987e21940387e27900387e27900187e27900187e23920387e21900987e3120787e23900587e25901121f89640240a1d89640240861988e48440861988e40440961588e4806488e0f89e401e408e098ae401e40863f9005903d902190079437942900d903102d900940d90290010312219017902100903100103101990110290110290007e500e482f2d065a2dbe6942b0f92091342069001000000000000000000000000000000000000000000000000000000000000000200000000000000001980790628039a4a8119e0196418202a1ca006a1c4006a1a82808f418829049e8e2d73faee668febd0a33f96fea0fd6d6d73a11b4206900100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000001306032e0bb240cc906c9023205b0218518232212c08c1223413021a508c10c1223250cc02c0a418508c90e688c382c0a41851a4198408c02c00c82c0a808a192620d04c80ec3a96c01ec82ec583ebb064204b26f0507ec3c080ba8f0303eb3fd00c0facf0202e63a9234206900100000000000000000000000000000000000000000000000000000000000000080000000000000000000001d880f87e28361fb820361fb820361fb820361fb8482e1fba402e1fba401e1f88f120587e238a3a402e6056238a3c402ee081188e1a8e100bba202e23ca386482ec382bbaa1b8a3a402e63bea5bc402ee20bdba402623862e6f1209b882fee10099abdba4026e20e18bdb84026620bfba401ee286ae6f100998c3862eee1209b8c20b9bc408079ac18b9ba40a0798c2062eee880798e18c2de63c281e638bdb863820266206ad66ba402663abb98e100b98c20bbba0b98e3063862cee83e638620b3ba15b8a3aabbc1bb8c29ef001fb8c39609f341b0b48f9783a163ffe6d8cfce65293f96ba3cfc65f243c1c6840fbb12b420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000004e402402404e400500404e4004084004056488485e40a010178c10ee10e640063790018de400e3380401640ae09007900902180402402640248240240364824384e503695064988286f42b0f93893342069001000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000001101f9005901b940390210199221001902101b902900902901988e40040a406623923101988e48c485e2190010219213902190088e4981650840064884896458c481650ee401e40de502e40c6484640b648664b83eb30641c8366fce65293893b42069001000000000000000000000000000000000000000000000000000000000000000300000000000000007e48161f902106087e408e4001f902390007e408e4186e408e48a485e408e40040a504e408648240c4380e458c400640964588e4380e40fe401e40ee482640de404650a6506649826930631e7b66fce6529389434206900100000000000000000000000000000000000000000000000000000000000000190000000000000000000000000000000000000000000000000000000000761f87f251200664060461f87f2d21190981187e1fc94194486c32181187e1fc94194486452180f87e1fcb4194c90510980f87e1fc86532192406510180d87e1fcae194992406526480987e1fcb44125064b01b2512100587e1fcb4cb4192010486ca40161f87f2530494ca0432506c8400e1f87f2c06482412026412d06484041f87ec4b4194c120070512386c84001f87f23125320b04801c1418e48650407e1fc8c294c82c1201709921b2101b87f230ad064520270992512101987f2ab41b04c09cb04a8121587f2a94c0643203f24084944840561fc8ad0c45283f243219048404e1fab4308c322011c9022640404e1fa8c50e214c815cb020e1187e250e214c019c90b86900f87f2094214c1206f240a386120d87f231421419007722103941840361fc94194c1207f241238682e1fca652240087e840e50611201e1fc8e19429050107e44141b201e1fc8e1942900061fc844264880161fb9529200e1f930192212010801fc8e5280920161f914188c9087702aed30480787e4528490a804817c9022a386510480987e450ec08d100674408b86502480987e45081c204815c344325320361fd124084905213c805070d10480d87f4108c3401004f403440e1aa480f87f440e41529203f0d122943863120461fd103b4a948273510d0ad064120461fd1050e50a512512530030290b942b4c94190481387f443429250a52a40152601252a412286481587f25125103b49a01c06532d0a4121b205e1fc8ac0e194486414034c0650e4b420e5120661fcb421049438652752e52e48e414481b87f5406494194c14490d2e1aec1206e1fd070c8641541445541441505e1fd2c2b4406c074990d2e510a8e53204e1fd0c2b0314414b92d12412190194c0a20ad21387f4310b142944144b015299153022e501387f4210314290334490480c8f438a50c44804e1fd08b1440cd12037438a5323b40561fd30b3483f43aa51239485e1fd2c5128474b90cb406e1f87f4387e06b4065bfa7a40373d4f96fcff3c318a1cf1ca7e23c629b88f2882f13c761f18f128abd3ce2cb5cf5db4da3c94b420690010000000000000000000000000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000580000000000000000000000000000000000000000000000000000000000000062000000000000000000000000000000000000000000000000000000000000006a0000000000000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000007c000000000000000000000000000000000000000000000000000000000000008200000000000000000000000000000000000000000000000000000000000000880000000000000000000000000000000000000000000000000000000000000092000000000000000000000000000000000000000000000000000000000000009800000000000000000000000000000000000000000000000000000000000000a200000000000000000000000000000000000000000000000000000000000000ac00000000000000000000000000000000000000000000000000000000000000b800000000000000000000000000000000000000000000000000000000000000c800000000000000000000000000000000000000000000000000000000000000d200000000000000000000000000000000000000000000000000000000000000e400000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000fc00000000000000000000000000000000000000000000000000000000000001080000000000000000000000000000000000000000000000000000000000000114000000000000000000000000000000000000000000000000000000000000011c00000000000000000000000000000000000000000000000000000000000001240000000000000000000000000000000000000000000000000000000000000132000000000000000000000000000000000000000000000000000000000000013800000000000000000000000000000000000000000000000000000000000001460000000000000000000000000000000000000000000000000000000000000154000000000000000000000000000000000000000000000000000000000000016200000000000000000000000000000000000000000000000000000000000001700000000000000000000000000000000000000000000000000000000000000182000000000000000000000000000000000000000000000000000000000000019600000000000000000000000000000000000000000000000000000000000001b000000000000000000000000000000000000000000000000000000000000001ba0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000011e5f884084084b82418c4182480e488e4836408488488403e478163901c3020041050031432671516e644081442069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000001d8a1b8c178861589613896118a608ee10e6038d6098b617880f8b418e616a1171b2f4001c4206900100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000297848b909d928d9285948188610898420298912818a61081888a610890838a622039a8908383e610802904e610098801e71064964a8458b8cd12f3e6a44749d09000454545418244206900100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000007e418107ea90087ea1876a7980da86028e92a0ba8222a3a422c6016a088a8e92c41805aa9286929605aa8ac2a2a980ea24a8a92ae03a862a2b39212a224b3a0a90129660042a68ac404b1803984a80288aa828407662a82a031c19679ec9c59ac3650d4c43315fa1d34202c420690010000000000000000000000000000000000000000000000000000000000000003000000000003b8fe3f806819e419e8006200e819e419e8036819651968036818641851841c883629c479a903e220612e622118a818418518418904e29a4398905e29c41a90268b0659c5b6499761d15fa1d344a4a71d1212b4a41834420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000533b401b12b525b52b20ccc4cca86c49e04e6e49e04cee3004aa4a048ee4904824cc8322928125c042921b1203228148f01922104ca4807c97020a486c4809c86e49049e09cce03a8c192616b1c484ad291171b2f4458b8cd1244b5244e9360d13375a144bcf9a910cc403c420690010000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000166126079849de0947b8041ae418e49c418310619063885184183106190638c41803907106583e7106384e69001c0799c190592a9ffffff47a77b6100045454541044420690010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000318fe3f8fe018de098de098de098de098de098de098de01894194614b9171b2f4004c4206900100000000000000000000000000000000000000000000000000000000000000020000000000000178a158c13886138861188e11886138861188e0f88e0f88e0f8960b89e098b610be08810b60789e118c1192418c72289562da94005442069001000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000016614612703681ae81062041805a06a06906206204a0622400681060081849829270081a80281012049821081062260081a89201a261261062001a06224806818812608620039802040168398806e85826c5064984ae4cdd6851265d87457e874d142b0f94185c4206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000011e1d94e1197e07884988e4026291e23900b88478864036291e30464f8564780e39064124ae4a4a71d1ffffff4086442069001000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000660a107e29a019c2841f8c68270a0387e299e280e1f8a678a0387e299e280e1f8a678a0187e31a62841f8a6180638a007e298609d67f8066d9261926f8266f946d84e61fe17987f8666907787669073801f9a41be107e718161f9ae13adc19492719c4ed5a3d19ac3ee4106c4206900100000000000000000000000000000000000000000000000000000000000000040007e61841f996007e6986e6f84e6191e7036659470049a059ae498640249811ae41983184046806591668866920198e519621926900198649962194710019c498623946390019c418e3146592019a49811a4199e4180398418039be481e418059b6418199b61d9a607b5419a824d90306074458c54115fa1d3410744206900100000000000000000000000000000000000000000000000000000000000000050000000000000000000000387e30061f880086107e3102841f8c400e1f8c400e1f896107e2103041f8840a40061f885021f880102108188001f8a92c198a51882c82819902106216a83e47a0ea20b04641a06226a0062391681a85a8880631221926a36038a48c51a8f80e2022824988288d85e828687981ba8e88482880261fa801c0419072ce1c9f6df465b8ef1187c0a346ab83c51cce8f14207c4206900100000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000461fc80f87e44c0787e42125841fc8423201291287e44884084a0ca24a1bca83084a01ca2486403f342c4a05c821ca481e44a40903121009c848894ae888d100bc864a423a4432e480fcae4c421e6bd284723872992b9684a11cae3cae19a83123120472b8721ae1b0188b1231204f2b8a4c6486a5033284f23aa3929c0d4815caea923c1242cca17caf48f049031286733923c12587f2f841fc9e15d8c19a8ab0114316d45da67951192036468ef3c513a4d8344d67fd1124669b44792ea112882f144084420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000b88e1b88638819886086086081592218e210607906088e019401921f87e1f87e1f87e1f87ea016a856b04aa213a2a80aa06a03681ac81aa0baa81ac8aa0faa8aa028613a86023418c624b97a5eb2473afbb91cebeee5e9a9a9978668c45a08c42069001000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000998e1d9960f9c418e671166826611e3b936601661263b93e0398498f64f981184b8f651980984b8fe519a4d8fe519a4d8fe519a4d8fe519a4d8fe4f980184f8f64f980184f8ee51980984d8ee4f981184d8e6519801984b8e6519801984d8d6519805984d8ce519805984f8be519809984f8a6559809985397e603661465f980d984f97e6046612e5f9815984997e605e61165f9819984397e60766145f98007e6105f98107e6176600e1f9859980787e6156602e1f9851980f87e6136604e1f9a459a1987e6926801f87e6821fe241a8bcb59c6d74f9519cafba190944206900100000000000000000000000000000000000000000000000000000000000000050000198179a059c139c059841a1198418059849a0d9a418059851a099a4980598508611e688498059850841884388498059850841884388498059850841884388498059849884998059c49c518649c019a41a41841a41a498641a11851a51a459851a098497e6006145f9a517e6006145f9801a49851851c51851a0986418641a01a41c41a059c09c11a09a01d0419e6a8c9c7fffffd14242454109c42069001000000000000000000000000000000000000000000000000000000000000000500107e4201204003d9081c8123b9289a8903b9091a89035b442272240b6c3aa4226006a040acba9689a0988b4b7a06046a0bfb003b0b5b1603b0a5b2eab009b26b32a1b00bb2a1b0a1b2b300db0a1b2a1b0b300db2a1b0a1b0ab211b2ab2b30a3215b4ab0ab0a301fb1e087ecaac87eca86c07ec286c801fb2a32107ed01f170679cbb443031f910707f444c317ad1a6d4df4449ea5510404481a8a44206900100000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000a0e0787e809690061fa0220e322087e8b8c81856918a22e21a160788601aa3a2a25e21ac09c418e5256b01e620662045a2ea82e9106c20d20c9462817a04306fa2a86ec206b0818c20c188aa1db46b06a0624a001fb46a0620622a821fb463063082c0387ec585ee3064a27c24f1961519ac3ee457e874d14f83ab4499761d16dbaf5428ac4206900100000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000120d87e4581e1f9160587e50c40161f9025900387e409e40061f9025941988059025922846281e409648a0d8a402e48b603886403e48ee404e438ae40a4076508650a4021f90e21900587e408640161f902181e1f903100587e48c40161f903100787e40c40161f903100787e48a401e1f9060987e50261f9060987e5016f506910d3e7100dcf5408b442069001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000056286630562384e2380650c603942d808016418840c028803641a881a17a8620a048280fa801882a11a8605e8a80998c19469899eab1da47c73fa11c090b34594b95918a4276420bc42069001000000000000000000000000000000000000000000000000000000000000000300000087e418407e41801415946822140990e29208c518c4806408e41c4086418064389e4780649841884f80e418418a479a079a4188459a401e4184188439a0f906292705650849809a5419061ab916f0fc445b43e911198ba410c442069001000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000187e887668466201ba270366a219a221a0b986806680a4180b98212806680a420602660a42219884a407a0292805e890898801e88a42017a04226a007a0a20210884e89081c801e81880a42011a242272007a06222a20fa0672209a06224a20ba8818e882e82a8980e8186a2211a069a88048286a888568a867a80a0a2061da4e0f87eaa21587ea4c41a09a5191c31504713b568f466b0fb9166a0d9420cc42069001000000000000000000000000000000000000000000000000000000000000000200000f940f92294111e23901102f8040c409e5004086408e4806488641826409641816489e481e488e482e48c483643825f0651e620711414e5408d4420690010000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000001c65db46a3469966c198c1a8c80c286b1e61b6e632628c84c287306b066b766a8c80ec2a63b2230236e6a8c82662861b023b56728c8366287323356728c84662a630230230232a1b1e6a8c856630a3023b2a32ab16628c86ec28c3aa81a8c7a8c076c2ac1a885a8c3a8c87ec2cc2a85b0a34ab0007ed2c89a8ec841fb760b87ec78671d066a87d27166a0d944d080891000a11453535347ffffff428dc4206900100000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000001a03baa05a43bac01ac3fac1288a83baa82a02a898a2035aa8180a1a89890ae89a8198a20722624a7a072066aa61a46da166a0aa063a2aba463a0b19e4d99682a028818e4184998418e8280aa818641a49a49a418ea84a22712610619061272c03a889c49a49a4986aa005a889c49986b026a2271a0a83ea226da2a04ea2467a2a066a247241fac818061fac13cf419c7aae10d0d6a4450528511414e547fffffd11414a11a0e442069001000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000680eea816d0eed006caa3b98d18032b0ee6aac18c29635a96ca2aa0b0aeaa0a1a2ca4aa0afa4a1a2ca06a1a2ea5a4ca883a8682ae83a8ca88d9068baa032a22642064226a300b2a21643a04a16a3001b2a20e43a04a0ec9803b2a20643a04a06c9807b2a20641a04206c980bb2a20641a06a320fb2a236a3213b2aa16a18c866c2c8aac87ec2cd03f250671ea384e4f0c912f694b44c2f9a9134202247fffffd12f694b1a8ec420690010000000000000000000000000000000000000000000000000000000000000006000987e203e1f8a0d87e2280b87ec08a8261fb022a0987ec0aa02e1fb8d07ec5b8ca8c38c01e2816e306e34ab8b38c026a8a6d10ab88b8a30e3209a863384b8838810e20e20e28c38c03ea1baa3889065a0a38c85eea8898c39a828e3019ba42073066a0e3219bca22a18d18828e321bbaaa263262ce301fbaaa0c1aa30a38c801fbaa1a02c038c041fbcaa0b300587ef286c0261fbcab00d87ef58419e9ad016a6a694531214d1a6a6a647a77b6111d274247fffffd15e5443430f44206900100000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000002e1f87e1f87e1f87eb1ae8041fac75876a98e81c098418e805ea1c42041c8048184986804ea1c4886a203a060a41c803ea1c48a62205988182906a8802ea1c48a6a009a0688498aa009a861429a80368182926aa05a8614318803e70a41ca2001aa812318804e81a21272801a861231a179c21081aa82aa048a686681a212680a02a1821021a80767084206a809a4086a0007e68a41a0200184a0620087e7084206a001840868061f9a210a2002229880161f98210aa002062a0787e710a20020a82e1f9ca200a00d87e72880561f988280fcc1b09b129525954471a6a6a647fffffd1f9f5f2420fc4206900100000000000000000000000000000000000000000000000000000000000000090000000000002e1f8c1d87e25921587e2995001e1f8c641c06107e2d91707821f8ae43c2ee801f93f0fbc087f13919b86107f17b8f0b8107f0fb9f118f07efbc26f06ef7c4ef05f01baf0980f03ad00370c7e09b8d29002f147e09b90b1082713b118313a07b90182f0bb0fb803c2e816e182f0ba142ee0170bc1bc0e017138044e01f0186703807c4e030b80bc0885703a07c2e050b80dc060bb80c0e02710070b809b9032a4005bb1280bc205c2e01ee42cc005b9130a00eec2e01f101ee44c4005b903403bb0ab000eec0a4205bb08270a9000ee44c290006ec2c2900261fb90b3000ee44c2900361fb30016ec2c42007e1fbb0186ff906cb4eda4629b891128abd45f77bc5100dcf544e2cb5d11d87c644318a1d12153741b90442069001000000000000000000000000000000000000000000000000000000000000000c00000000000000000011ac1dac0987ea24a066aa2a80e1fa88a86a817a862a8ac007ea22a1ca816a806b1c4206a86ea22a1072882a0aa92c828714a206a05ea2451a81aa85a88a8218419aa24a84ea22a10e9288da88a851c42a92811a2a1c4a881aa89a892841865289280da8898e421eaa06aa0ea1c4198a22a036a20a1061a887a8028602885a861067288a809a889472887a807a883aa518ea22a01ea224198a21ea026a216a9063928a807a882841aa87a80ba887a86194a20a01ea20712a21ea03ea21ea9851a82805a882861a889a811a887aa49aa22a00ea2049aa226a056a226b1842882803a8814a226a066a22ea9282801a882852889a81baa8b90a22a04a2071089a8007eaa26a22a02a227226a041faa8ba81288286a887a80587eaa1ea04a204aa85a80987eaa16a02a20a10aa16a03e1fa883a80a8818aa16a04e1faa9280a882887a81987ea22a02a216b0761fa88280288a8e087e1faa12a0f87e1f80c301b0db9a1c733c3d11128abd44318a1d118a6e24210c4206900100000000000000000000000000000000000000000000000000000000000000040000000000000000000000001f8850164184e31201922183e23920902122590039231229001029431205906239221902120b90279223901392621901790310010621017902900902941590310090310179060190212159029005922101390210099021011902100d902100f921192007edb0671c8367196fcff40914420690010000000000000000000000000000000000000000000000000000000000000002000001587e30fe108e0588e0588e0588e0588e0588e0588e0588e0588e0588e0588e0588e0588e0588e0588e0588e0588e0588e11441ae32e59c011c42069001000000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000000000004e0000000000000000000000000000000000000000000000000000000000000058000000000000000000000000000000000000000000000000000000000000005e00000000000000000000000000000000000000000000000000000000000000680000000000000000000000000000000000000000000000000000000000000078000000000000000000000000000000000000000000000000000000000000008c00000000000000000000000000000000000000000000000000000000000000960000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000004e1f900187e1f8c4041f87e40864021f87e40864041f901d902190007e40c485e4086407e21901b9021901b903101f88e199021801f9021901790310087e4086404e40860187e4086403e4086400e1f88e403640c40161f902390099021900787e408e40164086402e1f902190039023900b87e50c404408408502e1f902902902100103103100987e40a40848a48840840840840261f922902940102102102100d87e40840840a40440c40461f9031203941587e500785066b0b5c6342b0f90881542069001000000000000000000000000000000000000000000000000000000000000000400000389e0d8a4388098a4824880988480648262100388485e485e2101788485e2101788405e2101788405e2101790205e40817921990205e4081790205e4081792205e4081790202e28064080988480640809920390201e2100392201e21001922026212092282e21430464184e7068a2fa24910e083212b4a0881d420690010000000000000000000000000000000000000000000000000000000000000009000000000000000000000000001b2fdb40bb4fdb0e300bb2ffb0607b4ebfec81ed39e29b96c38c016cb962fb8ed00ed38e33b8ed006cb9635b8ed04c39637b96c82d38639b96d00d38639b9ec80cb8e3bb96c80cb863db96c38d3863db96c3b863fbcc7b8620feeb1ee18fec3ac7b863fb2e326f0fecfb8c383d98e346e0e66086a0c3bad1c379882a620c1bad18a8e6620a1aeb2eb262c8183198428620a18a38c38e62a8182d9829882a6aae7aa818aa2609662029882a62ae7aa62a81a409e808a9aa1b8603cb1a520c08e620a7bac3a0386a1aa108b26728ee32e02e32eac8336a5bccb80b8d38ecdb9ec1b8138cb7ee316e04e32edfb80008001a28c309212b4a0c5c6cbc32443826ffffffdb2e10386ced5a3db3a4d830b02542069001000000000000000000000000000000000000000000000000000000000000000400000087ea1a13aa6ac0da86ac6a013a0622a04e8ac15aa80815a881817a061015a2405e82817a0a85ea1017a8405e4181790605e885e82815a2a056b056a85ea2017a217a06056818a05682a15aa15ac07aa03a407ac0a881a09a4a582e622b041fb441a28c2892593f10c84ad2832f3e6a0c4a2bac33b568f0a02d420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000016a1a042a13a8810a83ea80808a8366028022036680a02a03622a110a05e81013ac8046a048046680a8462286a013886008066803ea006803ea18090a04660082815aa0a6c1a28a289a37eed0dfd8ed83baa0ee0d792a203cebeee0a0354206900100000000000000000000000000000000000000000000000000000000000000020066287e30762385e298462d83e2f83e25866238662d84e2002d8362802d82e302278363042383e21822184621806204e1f87e1f96c18cb24b18803d4206900100000000000000000000000000000000000000000000000000000000000000040000001e4184e458364b826438a502e418a482e438a4826290e21009886508402631062100b884782e2942120b8850848364188483650a403e5084080d94210210202e4380282643880f94290203650840a0d90e1194303e418c0d94212203e508404650840a0f906303e408502e1068a2e224912d483204046088454206900100000000000000000000000000000000000000000000000000000000000000070000005ea181e1fa865a80187ea1ae087ea1c21986a06ea9a30463a8199c281e72817a860c0b9ca04ea1a203e72811aa608139aa0466184e6a8119c159aa0361f886280d87e218a02e1f8a6280987e29aa01e1f8a6a80987e21aa0261f8a6280987e298a02e1f886a80987e298a006b021f886a802882852a1f8862a020419c80766a809411c1d9aa00a18400e6a81b9aa00a1a01a09aa06ea18a02a186092a06ea1c0286112a076a980794007ea9a11068021faa61928a8107eb1aa20a0261fac03e8c1a7043010734480de6363c30c62870f33c3d03128abd0a04d42069001000000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000000000bcb6087f289ed4a1dca2c9e23224a17c8e47ca233284f294f2b32847211e711720d203f2106a79a41c82c80fc84ac661520b2046b99320b204eac96a390a912092057201721a8e44a0587f2a8f281e1fc8a3c80987f2aa6480b87f2ab20361fc8ac80d87f22b20361fc8ac80d87f22b301e1fc8c38cbb2041fcae30ab8cb92821fc8e33022abb2001fc8e3283282ce48007f238c22c288ad2001fcb021030a308c0a48007f239021030a32a3b2021fc9029030a3303920061fc8a44c4328061fcae42c40e480587f2c07281e1fcb1480b87f24320361fc90c80f87f0481187f28461fc805ff41a8f49098c0d13ac318a6e20c0373d432882f10e5bf3fc34f77dd0c95573831ca7e20c05542069001000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000229876278262b8762b80e2d87e2d842382e1f89e08c1387e2580305e1f88608a1987e218028661f88600a1987e30428561f886108e0f87e300e2382e1f8860388e0987e2181e2180e1f89e098a0587e2387e1f886007e1f8c03a7c194ba3518805d42069001000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000118be1f886a9886158d00842ae40860db2240f10ab90e42282ec08e390ab910bb002ec40e80e90ab9103d002ec38f010a790a1105826c1aec24296892f4409b273a428e4a04b90bb0026630640710a5a0420442f400998c38e429e428440e3826630e392a990e5c00798c1cf10a9910bd081e630e9aec0a792ec06e01e630e427404ac53d01b807b0e1c2640e10ef42f4207b0e9b03b01b8f0b970016c406b9f1390ba70016c1aedc06e9c005b063a713d13871016c1ae5c2e7c16e4005b063bb0baf01bb001e6390986e9c4ec2e4007b0f1d01b8f038f0826c38738f13845bd0026c1aebc0420b2043d0026c18e9c4428e4b90826cb971384a964440bb303a6c0e1908ac840ec00db301b038e41c0440ec00f90cbb138f1390b9003651ae1c2ec2e1c40d90a1b966b9f003e4280b067c4e1c011aa0b463970bb00468a801b4e5c0e4017a805b10b87080e1fd1f2821fd52d525128774c8f4cb4cc19d121d121d1250e1dd323d12821fd32d1251201448007f44c05120120144a1fd12052812034c8107f4480ca0d00187f4480d120461fca0f87f4026038a06ec18c04bda52c330be6a0ced5a3c366a0d90cf0a1143fcdbcb0ce4f0c833139660e1dfa1031c31500c86542069001000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000036000000000000000000000000000000000000000000000000000000000000003c000000000000000000000000000000000000000000000000000000000000004a0000000000000000000000000000000000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000005e0000000000000000000000000000000000000000000000000000000000000064000000000000000000000000000000000000000000000000000000000000006e0000000000000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000007e0000000000000000000000000000000000000000000000000000000000000000400000000000000000000012710e7580e49829461266980e4182943790680e418418851b6408668449848a7026639029a01926920f9962980390e1192690608601650666106180e1f984184980587e70060161f9c01a0387e600680600e1f9a0180987e60060261f9801b3419689ef12e10382c5c6cbcb66b0d9290164206900100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000010e2184e211e210e0988478847856418a506e488507e4187e2941d8850762921d902141b902141b902921b922121994212199421219942121994012179060121592012012159009009215900120921990112007e487e5076480406e480487e480d106c24dac4a4a71cb2814502881e420690010000000000000000000000000000000000000000000000000000000000000004000000000022f6928600eb12bba2a00ea92b15eb00ea3a0488af8841aa128e498a826a394a806a22a1836b22a12a00e828611ac8a842803a8619a882860387ea3a00587eb008280387ea18a00880e1fa80220280387ea200200987e800a0261fa801b1c19689ef12814502e2909d8b2e10382c5b43e8b171b2f2a0264206900100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000010239805902190600e612310638069021906782e703668c418440c692814502e8dfbb4b562da92902e420690010000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000005a80398a008aa098800a03ea00aa2028628022a82620aa0a02ea00b22a18aa0a18a00620a00a20a02a02a00a00a00a00a22a1aa80628818a1aa20a200280a80286a0a18a182a82a00a1aa988aa0ac01aa9aa82a04a8062a6a0aa2028420a9aa82ea80a988280a88aa422a126056a7a2ad84eb08424a80a1ab076a780b00606ea98ea84a186ea780ea201da88280baa1dac03da419089d012443822f3afbb8be9ded82e6b0fb8b2f3e6a2a036420690010000000000000000000000000000000000000000000000000000000000000003000000000000000004886886618c09a2398609070a0590e6806239a01021828166126902181e418010218218118648a41a21806210692608658266188e49a090e604e619468161f98e0a3418680ef9a37eed2d58b6a4bcebeee2903e42069001000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000001c2780658468841a212e2198e290688419e418c68a49d650c6120980d986508686e69421a1f9840a6001f984086801f90298087e40a087e4841f984821f9a4041f984041f9a0187e60061f980187e6041f906021f98418007e680407e6824021f9a4001f9a010107e6841f9803cc1ac9b4c12929c72dd0fcfcbffffff2904642069001000000000000000000000000000000000000000000000000000000000000000200000000000000007623801f89e1b88e00a4856290200640021201942594039408a489e502e4022b940f900b87e4d060ae434727db7cb96e3bc2884e420690010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000316818c28c856c798c28ca2d021f90c2cd20007e430620a20622c28c06e430620c08c20007e420620c08c021f90c0ad20087eca0a00e1fb0620a14087ec206300387ec81e1fa0a32ab0652e636450c5b4b24669b2eb38b2d72c250dccb56678f2a85642069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000025180648a40a40a40a48040840a40a40a40a40848a48048048048a400483e48051061122a26b0202e62885e42069001000000000000000000000000000000000000000000000000000000000000000400000000000000011a1e1da061a0621a060ba26206022219c802689a107e8188841fa26200187e8120387e81080061fa060187e81a8041fa2422107e81280061fa0422107e8188841fa0e087e83821fa26206200187e818061fa00200387e800801e1fa0107ec30690cab658669f0bc8ead92dba50dcb2f694b2986642069001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000683e67804184006f906106f804184006982e6184e60b418440c79ad495964b6a6a692906e42069001000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000002800000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000004e0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000007200000000000000000000000000000000000000000000000000000000000000860000000000000000000000000000000000000000000000000000000000000094000000000000000000000000000000000000000000000000000000000000009e00000000000000000000000000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000b600000000000000000000000000000000000000000000000000000000000000c800000000000000000000000000000000000000000000000000000000000000d20000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000059a0b87e682e1f9a0b87e681e1f8a68261f8860587e2381e1f8860587e238261f982821f9c11a11c199849a01a0984981b9849801a0184981f984986498007e6146946021f984598087e6126607e6136606e614660666191661801f9a5180587e614601e1f984180987e702e1f980d87e6041fbb41820b4f1d45bc3f153c82b75101742069001000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000011a0387e680e1f9a0387e680e1f9a0387e680e1f9a0387e680e1f9a0387e680e1f9a0387e680e1f9a0387e680e1f9a0387e680e1f9a0387e680e1f9a0387e68061f982106021f982146001f98214607e60a41981d98210e607660843981d98210e607660843981f8a518007e608518087e6084180187e6821fbd419a0c0d1b4d4e5563e9ac953c82b75101f4206900100000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000004210087e210087e210087e210087e210087e210087e210087e210087e210087e210087e210087e210087e210007e81c1b98859817a01180a017a01180a215a011811815981181181598118118159811811815981181181598120602684e8006802884e81812012015a012012015a20a012017a0007f1106702e2e5a9a9a553f3b3554406ced52f3e6a51827420690010000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000139060787e50a480e1f922392087e48a64001f8840ae487633901d88648a6406e239029901b88e40a6406e239227901d88e4096487623902190e1d8c48a4886407e458c418061f902906622107e439868841f9281a81869021fa06a265a21fa072267a01ba06ba061a017a06fa00206a015a06a272272002217a411c91a80061fa07200206a00187e81c80081a80061fa26a00220787e88173f0653edc04002845566a0d954bda52c330be6a0982f42069001000000000000000000000000000000000000000000000000000000000000000800000000000000001ec18061fb141b0087ec516c001fb145b012c15b06a5430008a40613b085b02c0615b04a06c0b018564a0422c102c41790c1283048b086e4b083048aa86e41b008a1dd0030e107ee30622c041fb8c381207f20340061fc9439439401403407f200f014021fd0051200e01238007ee0123a1dd001c94380d0e077400e4b401285f481404e0544a087ef012067400e81402e01201201405f480f03250087ee4b40320061fb80381481fc80392381480d00501dba1481fc8048e05201e1fc80480187f400e1fd01387f4034021f87fd906a031b84c2f9a95ffffff57fffffc7eee9e65759f5b5b5d5a6a6a655d0fcfd5743f3f548374206900100000000000000000000000000000000000000000000000000000000000000080000000000002640461f920f87e50361f88e0987e292202e1f8960987e21428261f88e0b901b8a488059061d8a480648c487e484488e407e50040a48c487e508438c406e50c40c40c405e508e48a40c4046508650a438a401e4388640a4084086408488401640ae40a408408641884016489e48a50b64016408640a50ae48c401650c40840848965086401e40c40a4086508648864016488408e4189e4086401e40864084884388648c4816408640a508640c50c401e40c40c40840a48a4886501640c40c50ae4180401e3142f9411902902122794179221227941d922794087e408e50061f903140787e503e1f90007ff9061c11c075ffffff5083f4206900100000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000a11ec056a080080080084056a08008008008484ea08008008018c1013a8200200600600c04ea0800800801803013a8200200200600c04ea0800800801803013a8200200200200c04ea0800800800801013a8200200600200404ea0800801800801013a8200200600600404ea0800801801801013a8200200600600404ea0800800801801013a8200200200600404ea0801801801803013a820020020023213a820020020043015a8200200600c05ea08018018c85ea08018018c066a08008010c066a080180301ba86008321ba86204301da8620c07ea22c07ea32007ea30087e022a06882fae4bcf9a95212b4a54910e095aae0f154e9360d5ffffff528474206900100000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000004c985621a6c04621b611b073067300fb06b2ab27300bb0730a1b07300bb0732ab27300bb0710c1986c02ec9a4b261b20db0692c986c03ec984b273211b24b2688c056c12c9a205ec1843268817b0610c9ac05ec184326b017b0610c9ac05ec084326308066c3a01fb2087ec821fb2087ec821fb2087ec821fb2087ec801fb0ab0007ea801fb0ab0007ea801fb0ab0007ec85f4d067830ae4a051415d4bcf9a956dbaf5550ac3e55150b2a5284f4206900100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000001da4107e9041f928041f8a4821f922821fa05021fa4107e9041fa41da36a05681aea05681aea056818eb18a05681882a62862862815a062062872862815a062c62c62815a06ba815a0ada94186b24c9150b2a57530be6a550ac3e552665ac5205742069001000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000044387e409e406e2b9017902d9015902d90159021902390159031421901590314219015903142190178b6199829901b9825901f982190007e40864001f902190087e60a4041f9860187e680e1f9a0387e680e1f9a0387e680e1f9a0387e680e1f9a0187e41a40061f9a0387e68061f9061060061f9a1fbac1940bcd1212b4a545c6cbd52929c75105f4206900100000000000000000000000000000000000000000000000000000000000000050000000000000000001ead86ea1a16728e0daa8f9868aa09aa627e07a86a09f81ea188a7e07a883aa625607a88598a18818887826a2222066286a42a0e09a88888398b188583ea22220ea00a5a20fa889a805aa11aa89a8007ea21ea187ea202206aa0b06eaa022462a8a81daa808918a22a07eaa02216a021fa885aa107eaa2a81e1fac1bc1c1860aaf1d4d67fd152665ac54964fc559ac3ee52067420690010000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000158a402e1f8a50261f8848a0987e210282e1f88418261f8a418165181b8a50065184981b8a50249864181d8c408498e418007e310602692107e212c0361f906340787e498c18161f906b2a00c00e1f90602c2a0300187e4180b2ab2107e418134a300987ed28c8261fb0e0987ed28c02e1fb28320987ed28c0261fb4a320987eca8c8261fb0828c8261fb0828c8261fb0828c8261fb08340987ec20a3080261fb08340987ec20d0261fb0a340987ec28c82e1fb0a320b87ec18261fb0a320b87ec28c82e1fb20d87ec8361fb20f87ec01fbb065c14c06deb66d5ffffff561dfa11566a0d954ed5a3d51c31505286f4206900100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000001a0387e61824004004036400400402618a40840840b640840840a618045836458061804041f9860387e680600e1f980980387e60461f87e1f87e1f87e1f87e1f87e1f87e1f87e1f87e1f87e1f87e1f87e1fa7c194730e1b7ad9b550ac3e552040465107742069001000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000218662585627856818a15a0e15906684e51849a11928985180f9081889a4180fa0610818890603e6126106604e620419813916604e500420604e4980108181192602420604649809081811906048876804eb5062829a850ac3e551e4ba854d67fd1587c0a35187f42069001';
}

// Success: test__system1()

//   users length: 2000
//   nuggft.eps(): 36422938319266817
//   nuggft.proto(): 13721927850988207037
//   nuggft.staked(): 254960568234867720007
//   nuggft.shares(): 7000

// Success: test__system1()

//   users length: 2000
//   nuggft.eps(): .220269870602728762
//   nuggft.proto(): 105.652900187038601090
//   nuggft.staked(): 3524.317929643660202576
//   nuggft.shares(): 16000

// Success: test__system1()
// *10
//   users length: 2000
//   nuggft.eps():  .081046931383505748
//   nuggft.proto(): 36.036371675422002761
//   nuggft.staked():  891.516245218563229016
//   nuggft.shares(): 11000

//   users length: 2000
//   nuggft.eps():   .009923420616251655
//   nuggft.proto():  10.797105517187750828
//   nuggft.staked():   109.157626778768205405
//   nuggft.shares(): 11000

// Success: test__system1()

//   users length: 2000
//   nuggft.eps(): .023820112972809680
//   nuggft.proto(): 23.605706549631210195
//   nuggft.staked(): 262.021242700906482643
//   nuggft.shares(): 11000

// Success: test__system1()

//   users length: 2000
//   nuggft.eps(): 22283800801842573
//   nuggft.proto(): 12045486919914902312
//   nuggft.staked(): 133702804811055442627
//   nuggft.shares(): 6000

//   users length: 2000
//   nuggft.eps(): 1.124042581556443270
//   nuggft.proto(): 658.232592803322633239
//   nuggft.staked(): 7306.276780116881258328
//   nuggft.shares(): 6500

// Success: test__system1()

//   users length: 2000
//   nuggft.eps(): .179846813049030914
//   nuggft.proto(): 105317214848531614175
//   nuggft.staked(): 1169004284818700946598
//   nuggft.shares(): 6500

// .092595956292375926

// .101719406217199627

// Success: test__system1()

//   users length: 2000
//   nuggft.eps(): .178270406414740660
//   nuggft.proto(): 96363895359319273644
//   nuggft.staked(): 1069622438488443964472
//   nuggft.shares(): 6000

// Success: test__system1()

//   users length: 1000
//   nuggft.eps():   1.425741271002990526
//   nuggft.proto():  305.518843786355111578
//   nuggft.staked():   4277.223813008971579744
//   nuggft.shares(): 3000

//
