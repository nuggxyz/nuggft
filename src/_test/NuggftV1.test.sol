// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {MockNuggftV1Migrator} from "./mock/MockNuggftV1Migrator.sol";

import {NuggftV1Constants} from "../core/NuggftV1Constants.sol";

import {Expect} from "./expect/Expect.sol";

import {DotnuggV1Lib} from "dotnugg-v1-core/DotnuggV1Lib.sol";
import {IDotnuggV1} from "dotnugg-v1-core/IDotnuggV1.sol";

import {NuggftV1AgentType} from "./helpers/NuggftV1AgentType.sol";

import {RiggedNuggFatherV1} from "./RiggedNuggFatherV1.sol";
import {RiggedNuggftV1} from "./RiggedNuggftV1.sol";
import {IxNuggftV1} from "../interfaces/nuggftv1/IxNuggftV1.sol";

import "./utils/forge.sol";

library SafeCast {
    function safeInt(uint96 input) internal pure returns (int192) {
        return (int192(int256(uint256(input))));
    }
}

contract NuggftV1Test is ForgeTest, NuggftV1Constants {
    using SafeCast for uint96;
    using SafeCast for uint256;
    using SafeCast for uint64;

    IDotnuggV1 public dotnugg;

    MockNuggftV1Migrator public migrator;

    RiggedNuggftV1 internal nuggft;

    IxNuggftV1 internal xnuggft;

    RiggedNuggFatherV1 internal father;

    address public _nuggft;
    address public _dotnugg;
    address public _proxy;
    address public _xnuggft;

    Expect expect;

    address internal dub6ix = 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77;

    // constructor() {}

    function trustMintable(uint24 input) public view returns (uint24) {
        return earlyMintable(input) + nuggft.early();
    }

    function mintable(uint24 input) public view returns (uint24) {
        return earlyMintable(input);
    }

    function earlyMintable(uint24 input) public pure returns (uint24) {
        return MINT_OFFSET + input;
    }

    function createInstance(address creator, uint96 value) private {
        ds.setDsTest(address(this));

        forge.vm.deal(creator, value);

        forge.vm.startPrank(creator);

        nuggft = new RiggedNuggftV1{value: value}();

        xnuggft = nuggft.xnuggftv1();

        _xnuggft = address(xnuggft);

        dotnugg = nuggft.dotnuggv1();

        migrator = new MockNuggftV1Migrator();

        _nuggft = address(nuggft);

        expect = new Expect(_nuggft);

        _dotnugg = address(dotnugg);

        nuggft.setIsTrusted(users.safe, true);

        forge.vm.stopPrank();

        jumpStart();
    }

    function resetManual(address trusted, uint96 value) public {
        createInstance(trusted, value);
    }

    function reset() public {
        createInstance(dub6ix, 10 ether);
    }

    function getAllNuggs() public view returns (uint24[] memory res) {
        bytes memory _check = xnuggft.tloop();

        uint256 len = _check.length / 3;

        res = new uint24[](len);

        for (uint256 i = 0; i < len; i++) {
            res[i] = uint24(bytes3(byteslib.slice(_check, i * 3, 3)));
        }
    }

    // function reset__fork() public {
    //     ds.setDsTest(address(this));
    //     NuggFatherV1 dep = new NuggFatherV1(data);

    //     // dep.init();

    //     dotnugg = IDotnuggV1Safe(dep.dotnugg());
    //     nuggft = new RiggedNuggft(address(dotnugg));

    //     // record.build(nuggft.external__agency__slot());

    //     _nuggft = address(nuggft);

    //     expect = new Expect(_nuggft);

    //     _dotnugg = address(dotnugg);

    //      migrator = new MockNuggftV1Migrator();

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

    function jumpStart() public {
        jump(OFFSET);
    }

    function jumpUp(uint256 amount) public {
        jump(nuggft.epoch() + uint24(amount));
    }

    function jumpSwap() public {
        jump(nuggft.epoch() + uint24(SALE_LEN) + 1);
    }

    function jumpLoan() public {
        jump(nuggft.epoch() + uint24(LIQUIDATION_PERIOD) + 1);
    }

    function jumpLoanDown(uint256 amount) public {
        jump(nuggft.epoch() + uint24(uint24(LIQUIDATION_PERIOD) + 1 - amount));
    }

    function hopUp(uint256 amount) public {
        forge.vm.roll(block.number + amount);
    }

    function encodeRevert(bytes1 code) internal pure returns (bytes memory) {
        return abi.encodePacked(Revert.selector, code);
    }

    function encItemId(
        uint24 buyerTokenId,
        uint24 tokenId,
        uint16 itemId
    ) internal pure returns (uint64) {
        return uint64((uint256(buyerTokenId) << 40) | (uint256(itemId) << 24) | uint256(tokenId));
    }

    function encItemIdClaim(uint24 tokenId, uint16 itemId) internal pure returns (uint40) {
        return uint40(uint256(itemId) << 24) | tokenId;
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

    function mintHelper(
        uint24 tokenId,
        address user,
        uint256 value
    ) public {
        expect.offer().from(user).exec{value: value}(tokenId);
        jumpSwap();
        expect.claim().from(user).exec(tokenId, user);
    }

    function mintHelper(
        uint24 tokenId,
        address user,
        uint256 value,
        bytes1 err
    ) public {
        expect.offer().err(err).from(user).exec{value: value}(tokenId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function scenario_dee_has_a_token() public payable returns (uint24 tokenId) {
        tokenId = mintable(1069);
        mintHelper(tokenId, users.dee, nuggft.msp());
    }

    function scenario_frank_has_a_token_and_spent_50_eth() public payable returns (uint24 tokenId) {
        tokenId = mintable(1021);

        mintHelper(tokenId, users.frank, 50 ether);
    }

    function scenario_frank_has_a_loaned_token() public payable returns (uint24 tokenId) {
        scenario_charlie_has_a_token();

        tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        // forge.vm.prank(users.frank);
        // nuggft.approve(_nuggft, tokenId);

        forge.vm.prank(users.frank);
        nuggft.loan(array.b24(tokenId));
    }

    function scenario_frank_has_a_loaned_token_that_has_expired() public payable returns (uint24 tokenId) {
        tokenId = scenario_frank_has_a_loaned_token();

        jumpLoan();
    }

    function scenario_dee_has_a_token_2() public payable returns (uint24 tokenId) {
        tokenId = mintable(1900);

        mintHelper(tokenId, users.dee, nuggft.msp());
    }

    function scenario_charlie_has_a_token() public payable returns (uint24 tokenId) {
        tokenId = mintable(1700);

        mintHelper(tokenId, users.charlie, nuggft.msp());
    }

    function scenario_migrator_set() public payable {
        forge.vm.prank(users.safe);
        nuggft.setMigrator(address(migrator));
    }

    function scenario_dee_has_a_token_and_can_sell() public payable returns (uint24 tokenId) {
        tokenId = scenario_dee_has_a_token();

        // forge.vm.prank(users.dee);
        // nuggft.approve(_nuggft, tokenId);
    }

    function scenario_dee_has_sold_a_token() public payable returns (uint24 tokenId, uint96 floor) {
        tokenId = scenario_dee_has_a_token_and_can_sell();

        floor = 1 ether;

        expect.sell().from(users.dee).exec(tokenId, floor);
    }

    function scenario_dee_has_sold_a_token_and_mac_has_offered() public payable returns (uint24 tokenId, uint96 eth) {
        (tokenId, ) = scenario_dee_has_sold_a_token();

        eth = 2 ether;

        expect.offer().from(users.mac).exec{value: eth}(tokenId);
    }

    function scenario_dee_has_sold_a_token_and_mac_can_claim() public payable returns (uint24 tokenId) {
        (tokenId, ) = scenario_dee_has_sold_a_token_and_mac_has_offered();

        jumpSwap();
    }

    function scenario_mac_has_claimed_a_token_dee_sold() public payable returns (uint24 tokenId) {
        (tokenId) = scenario_dee_has_sold_a_token_and_mac_can_claim();

        expect.claim().from(users.mac).exec(array.b24(tokenId), lib.sarrAddress(users.mac));
    }

    function scenario_mac_has_sold_a_token_dee_sold() public payable returns (uint24 tokenId, uint96 floor) {
        (tokenId) = scenario_mac_has_claimed_a_token_dee_sold();

        floor = nuggft.eps() * 2;

        expect.sell().from(users.mac).exec(tokenId, floor);
    }

    function scenario_dee_has_a_token_and_can_sell_an_item()
        public
        payable
        returns (
            uint24 tokenId,
            uint16 itemId,
            uint8 feature
        )
    {
        (tokenId) = scenario_dee_has_a_token();

        uint16[16] memory f = xnuggft.floop(tokenId);

        feature = 1;
        itemId = uint16(f[feature]);

        // _nuggft.shouldPass(dee, rotate(tokenId, feature));
    }

    function scenario_dee_has_sold_an_item()
        public
        payable
        returns (
            uint24 tokenId,
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
            uint24 charliesTokenId,
            uint24 tokenId,
            uint16 itemId
        )
    {
        uint256 feature;
        uint96 floor;
        (tokenId, feature, itemId, floor) = scenario_dee_has_sold_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        expect.offer().from(users.charlie).exec{value: floor + 1 ether}(charliesTokenId, tokenId, itemId);

        jumpSwap();
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
    //     uint24 count = 501;

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
    //     uint24 count = 501;

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

// address res;

// assembly {
//     mstore(0x02, caller())
//     mstore8(0x00, 0xD6)
//     mstore8(0x01, 0x94)
//     mstore8(0x16, 0x01)

//     res := shr(96, shl(96, keccak256(0x00, 0x17)))
// }

// firse index of sender
