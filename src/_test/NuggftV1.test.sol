// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import {MockNuggftV1Migrator} from "./mock/MockNuggftV1Migrator.sol";

import {NuggftV1} from "../NuggftV1.sol";
import {IDotnuggV1Safe} from "../interfaces/dotnugg/IDotnuggV1Safe.sol";
import {NuggFatherV1} from "../_deployment/NuggFatherV1.sol";
import {NuggftV1Constants} from "../core/NuggftV1Constants.sol";

import {Expect} from "./expect/Expect.sol";

import {data} from "../_data/nuggs.data.sol";

import "./utils/forge.sol";
import {DotnuggV1} from "../../../dotnugg-v1-core/src/DotnuggV1.sol";
import {DotnuggV1Lib} from "../libraries/DotnuggV1Lib.sol";

import {NuggftV1AgentType} from "./helpers/NuggftV1AgentType.sol";

contract RiggedNuggft is NuggftV1 {
    constructor(address dotnuggv1) NuggftV1(dotnuggv1) {
        // featureLengths = 0x0303030303030303;
    }

    function getBlockHash(uint256 blocknum) internal view override returns (bytes32 res) {
        if (block.number > blocknum && block.number - blocknum < 256) {
            return keccak256(abi.encodePacked(blocknum));
        }
    }

    function external__search(uint8 feature, uint256 seed) external view returns (uint8) {
        return DotnuggV1Lib.search(address(dotnuggV1), feature, seed);
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

    function external__calc(uint96 a, uint96 b) external pure returns (uint96 resa, uint96 resb) {
        return calc(a, b);
    }

    function external__toStartBlock(uint24 _epoch, uint32 gen) public view returns (uint256 res) {
        return toStartBlock(_epoch, gen);
    }

    function external__toStartBlock(uint24 _epoch) public view returns (uint256 res) {
        return toStartBlock(_epoch, genesis);
    }

    function external__toEndBlock(uint24 _epoch, uint32 gen) public view returns (uint256 res) {
        return toEndBlock(_epoch, gen);
    }

    function external__toEpoch(uint256 blocknum, uint256 gen) public view returns (uint256 res) {
        return toEpoch(blocknum, gen);
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

contract NuggftV1Test is ForgeTest, NuggftV1Constants {
    using SafeCast for uint96;
    using SafeCast for uint256;
    using SafeCast for uint64;

    IDotnuggV1Safe public processor;

    MockNuggftV1Migrator public _migrator;

    RiggedNuggft internal nuggft;

    constructor() {
        ds.setDsTest(address(this));
    }

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

    modifier globalDs() {
        ds.setDsTest(address(this));
        _;
    }

    function reset() public {
        forge.vm.roll(1000);
        // bytes memory tmp = hex'000100';
        ds.setDsTest(address(this));

        // dep.init();

        processor = IDotnuggV1Safe(address(new DotnuggV1()));
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

    // function reset__fork() public {
    //     ds.setDsTest(address(this));
    //     NuggFatherV1 dep = new NuggFatherV1(data);

    //     // dep.init();

    //     processor = IDotnuggV1Safe(dep.dotnugg());
    //     nuggft = new RiggedNuggft(address(processor));

    //     // record.build(nuggft.external__agency__slot());

    //     _nuggft = address(nuggft);

    //     expect = new Expect(_nuggft);

    //     _processor = address(processor);

    //     _migrator = new MockNuggftV1Migrator();

    //     users.frank = forge.vm.addr(12);
    //     forge.vm.deal(users.frank, 90000 ether);

    //     users.dee = forge.vm.addr(13);
    //     forge.vm.deal(users.dee, 90000 ether);

    //     users.mac = forge.vm.addr(14);
    //     forge.vm.deal(users.mac, 90000 ether);

    //     users.dennis = forge.vm.addr(15);
    //     forge.vm.deal(users.dennis, 90000 ether);

    //     users.charlie = forge.vm.addr(16);
    //     forge.vm.deal(users.charlie, 90000 ether);

    //     users.safe = forge.vm.addr(17);
    //     forge.vm.deal(users.safe, 90000 ether);

    //     forge.vm.startPrank(0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
    //     nuggft.setIsTrusted(users.safe, true);
    //     forge.vm.stopPrank();
    // }

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

        assertEq(got, exp, "balance did not change correctly");
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

    function check() internal {
        for (uint256 i = 0; i < _baldiffarr.length; i++) {
            assertEq(_baldiffarr[i].user.balance, _baldiffarr[i].expected, "checkBalChange");
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

        expect.mint().from(users.dee).exec(tokenId);
    }

    function scenario_frank_has_a_token_and_spent_50_eth() public payable returns (uint160 tokenId) {
        tokenId = 2012;

        expect.mint().from(users.frank).exec{value: 50 ether}(tokenId);
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

        expect.sell().from(users.dee).exec(tokenId, floor);
    }

    function scenario_dee_has_sold_a_token_and_mac_has_offered() public payable returns (uint160 tokenId, uint96 eth) {
        (tokenId, ) = scenario_dee_has_sold_a_token();

        eth = 2 ether;

        expect.offer().from(users.mac).exec{value: eth}(tokenId);
    }

    function scenario_dee_has_sold_a_token_and_mac_can_claim() public payable returns (uint160 tokenId) {
        (tokenId, ) = scenario_dee_has_sold_a_token_and_mac_has_offered();

        forge.vm.roll(nuggft.epoch() + SALE_LEN + 1);
    }

    function scenario_mac_has_claimed_a_token_dee_sold() public payable returns (uint160 tokenId) {
        (tokenId) = scenario_dee_has_sold_a_token_and_mac_can_claim();

        expect.claim().from(users.mac).exec(lib.sarr160(tokenId), lib.sarrAddress(users.mac));
    }

    function scenario_mac_has_sold_a_token_dee_sold() public payable returns (uint160 tokenId, uint96 floor) {
        (tokenId) = scenario_mac_has_claimed_a_token_dee_sold();

        floor = 3 ether;

        expect.sell().from(users.mac).exec(tokenId, floor);
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

        expect.sell().from(users.dee).exec(tokenId, itemId, floor);
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

        expect.offer().from(users.charlie).exec{value: floor + 1 ether}(charliesTokenId, tokenId, itemId);

        forge.vm.roll(nuggft.epoch() + SALE_LEN + 1);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                encodeWithSelector
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

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
