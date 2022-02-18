// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {MockNuggftV1Migrator} from './mock/MockNuggftV1Migrator.sol';

import {NuggftV1} from '../NuggftV1.sol';
import {IDotnuggV1} from '../interfaces/dotnugg/IDotnuggV1.sol';
import {NuggFatherV1} from '../_deployment/NuggFatherV1.sol';

import {Expect} from './expect/Expect.sol';

import {data} from '../_data/nuggs.data.sol';

import './utils/forge.sol';

import {NuggftV1AgentType} from './helpers/NuggftV1AgentType.sol';

contract RiggedNuggft is NuggftV1 {
    constructor(address dotnuggv1) NuggftV1(dotnuggv1, abi.decode(data, (bytes[]))) {
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
        ds.inject.log(_epoch, genesis, block.number);
        return toStartBlock(_epoch, genesis);
    }

    function external__agency__slot() public view returns (bytes32 res) {
        assembly {
            res := agency.slot
        }
    }

    function external__LOSS() public view returns (uint256 res) {
        res = LOSS;
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

    IDotnuggV1 public processor;

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

        NuggFatherV1 dep = new NuggFatherV1(data);

        // dep.init();

        processor = IDotnuggV1(dep.dotnugg());
        nuggft = new RiggedNuggft(address(processor));

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

        NuggFatherV1 dep = new NuggFatherV1(data);

        // dep.init();

        processor = IDotnuggV1(dep.dotnugg());
        nuggft = new RiggedNuggft(address(processor));
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

        NuggFatherV1 dep = new NuggFatherV1(data);

        // dep.init();

        processor = IDotnuggV1(dep.dotnugg());
        nuggft = new RiggedNuggft(address(processor));

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
        NuggFatherV1 dep = new NuggFatherV1(data);

        // dep.init();

        processor = IDotnuggV1(dep.dotnugg());
        nuggft = new RiggedNuggft(address(processor));

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

        bytes2[] memory f = nuggft.floop(tokenId);

        feature = 1;
        itemId = uint16(f[feature]);

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
