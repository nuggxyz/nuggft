// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {User} from '../utils/User.sol';

import {MockdotnuggV1Processor} from '../../_mock/MockdotnuggV1Processer.sol';

import {MockNuggFTV1Migrator} from '../../_mock/MockNuggFTV1Migrator.sol';

import {NuggFT} from '../../NuggFT.sol';

contract RiggedNuggft is NuggFT {
    constructor(address processor) NuggFT(processor) {
        globalPointerForTesting().file.lengthData = 0x0303030303030303;
    }
}

library SafeCast {
    function safeInt(uint96 input) internal pure returns (int192) {
        return (int192(int256(uint256(input))));
    }
}

contract NuggFatherFix is t {
    using SafeCast for uint96;
    using SafeCast for uint256;
    using SafeCast for uint64;

    MockdotnuggV1Processor public processor;

    MockNuggFTV1Migrator public migrator;

    RiggedNuggft public nuggft;

    User public safe;

    User public frank;
    User public charlie;
    User public dennis;
    User public mac;
    User public dee;

    User public any;

    function reset() public {
        fvm.roll(1);
        fvm.roll(2);
        processor = new MockdotnuggV1Processor();
        migrator = new MockNuggFTV1Migrator();
        nuggft = new RiggedNuggft(address(processor));

        safe = new User{value: 1000 ether}();
        frank = new User{value: 1000 ether}();
        charlie = new User{value: 1000 ether}();
        dennis = new User{value: 1000 ether}();
        mac = new User{value: 1000 ether}();
        dee = new User{value: 1000 ether}();

        any = new User();

        nuggft.setIsTrusted(address(safe), true);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                eth modifiers
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    struct ChangeCheck {
        int192 before_staked;
        int192 before_protocol;
        int192 before_shares;
        int192 before_minSharePrice;
        int192 before_eps;
        //
        int192 after_staked;
        int192 after_protocol;
        int192 after_shares;
        int192 after_minSharePrice;
        int192 after_eps;
    }

    modifier changeInStaked(int192 change, int192 shareChange) {
        ChangeCheck memory str;
        str.before_staked = nuggft.totalStakedEth().safeInt();
        str.before_protocol = nuggft.totalProtocolEth().safeInt();
        str.before_shares = nuggft.totalStakedShares().safeInt();
        str.before_minSharePrice = nuggft.minSharePrice().safeInt();

        str.before_eps = nuggft.activeEthPerShare().safeInt();

        assertEq(
            str.before_eps,
            str.before_shares > 0 ? str.before_staked / str.before_shares : int256(0),
            'EPS is starting off with an incorrect value'
        );

        _;
        str.after_staked = nuggft.totalStakedEth().safeInt();
        str.after_protocol = nuggft.totalProtocolEth().safeInt();
        str.after_shares = nuggft.totalStakedShares().safeInt();
        str.after_minSharePrice = nuggft.minSharePrice().safeInt();

        assertTrue(str.after_minSharePrice >= str.before_minSharePrice, 'minSharePrice is did not increase as expected');
        assertEq(str.after_protocol - str.before_protocol, take(10, change), 'totalProtocol is not what is expected');
        assertEq(str.after_staked - str.before_staked, change - take(10, change), 'staked change is not 90 percent of expected change');
        assertEq(str.after_shares - str.before_shares, shareChange, 'shares difference is not what is expected');

        str.after_eps = nuggft.activeEthPerShare().safeInt();
        assertEq(
            str.after_eps,
            str.after_shares > 0 ? str.after_staked / str.after_shares : int256(0),
            'EPS is not ending with correct value'
        );
    }

    modifier changeInUserBalance(User user, int192 change) {
        ChangeCheck memory str;

        str.before_staked = int192(int256(uint256(address(user).balance)));
        _;
        str.after_staked = int192(int256(uint256(address(user).balance)));

        assertEq(str.after_staked - str.before_staked, change, 'user balance did not change');
    }

    modifier changeInNuggftBalance(int192 change) {
        ChangeCheck memory str;

        str.before_staked = int192(int256(uint256(address(nuggft).balance)));
        _;
        str.after_staked = int192(int256(uint256(address(nuggft).balance)));

        assertEq(str.after_staked - str.before_staked, change, 'nuggft balance did not change');
    }

    // modifier changeInMinSharePrice(int192 change) {
    //     int192 bef = int192(int256(uint256(nuggft.minSharePrice())));
    //     _;
    //     int192 aft = int192(int256(uint256(nuggft.minSharePrice())));

    //     assertEq(aft - bef, change);
    // }

    // modifier changeInStakedShares(int192 change) {
    //     int192 bef = int192(int256(uint256(nuggft.totalStakedShares())));
    //     _;
    //     int192 aft = int192(int256(uint256(nuggft.totalStakedShares())));

    //     assertEq(aft - bef, change);
    // }

    // modifier changeInStakedEth(int192 change) {
    //     int192 bef = int192(int256(uint256(nuggft.totalStakedEth())));
    //     _;
    //     int192 aft = int192(int256(uint256(nuggft.totalStakedEth())));

    //     assertEq(aft - bef, change);
    // }

    function nuggft_call(User user, bytes memory args) public payable {
        nuggft_call(user, args, 0);
    }

    function nuggft_call(
        User user,
        bytes memory args,
        uint96 eth
    ) public payable {
        user.call(address(nuggft), args, eth);
    }

    function nuggft_revertCall(
        string memory message,
        User user,
        bytes memory args
    ) public payable {
        nuggft_revertCall(message, user, args, 0);
    }

    function nuggft_revertCall(
        string memory message,
        User user,
        bytes memory args,
        uint96 eth
    ) public payable {
        user.revertCall{value: eth}(address(nuggft), message, args);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                encodeWithSelector
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function delegate(address sender, uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.delegate.selector, sender, tokenId);
    }

    function delegateItem(
        uint256 buyerTokenId,
        uint256 sellerTokenId,
        uint256 itemId
    ) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.delegateItem.selector, buyerTokenId, sellerTokenId, itemId);
    }

    function claim(address sender, uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.claim.selector, sender, tokenId);
    }

    function swap(uint256 tokenId, uint96 floor) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.swap.selector, tokenId, floor);
    }

    function loan(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.loan.selector, tokenId);
    }

    function payoff(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.payoff.selector, tokenId);
    }

    function rebalance(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.rebalance.selector, tokenId);
    }

    function loanInfo(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.loanInfo.selector, tokenId);
    }

    function swapItem(
        uint256 tokenId,
        uint256 itemId,
        uint96 floor
    ) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.swapItem.selector, tokenId, itemId, floor);
    }

    function claimItem(
        uint256 buyerTokenId,
        uint256 sellerTokenId,
        uint256 itemId
    ) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.claimItem.selector, buyerTokenId, sellerTokenId, itemId);
    }

    function rotateFeature(uint256 tokenId, uint256 feature) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.rotateFeature.selector, tokenId, feature);
    }

    function withdrawStake(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.withdrawStake.selector, tokenId);
    }

    function migrateStake(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.migrateStake.selector, tokenId);
    }

    function setMigrator(address _migrator) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.setMigrator.selector, _migrator);
    }

    function approve(address addr, uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.approve.selector, addr, tokenId);
    }

    function setApprovalForAll(address addr, bool appr) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.setApprovalForAll.selector, addr, appr);
    }

    function mint(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.mint.selector, tokenId);
    }

    function trustedMint(uint256 tokenId, address to) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.trustedMint.selector, tokenId, to);
    }

    function take(int256 percent, int256 value) internal pure returns (int256) {
        return (value * percent) / 100;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function scenario_dee_has_a_token() public payable returns (uint160 tokenId) {
        tokenId = 2069;
        nuggft_call(dee, mint(tokenId));
    }

    function scenario_frank_has_a_token_and_spent_50_eth() public payable returns (uint160 tokenId) {
        tokenId = 2012;
        nuggft_call(frank, mint(tokenId), 50 ether);
    }

    function scenario_frank_has_a_loaned_token() public payable returns (uint160 tokenId) {
        scenario_charlie_has_a_token();

        tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        {
            nuggft_call(frank, approve(address(nuggft), tokenId));
        }

        nuggft_call(frank, loan(tokenId));
    }

    function scenario_frank_has_a_loaned_token_that_has_expired() public payable returns (uint160 tokenId) {
        tokenId = scenario_frank_has_a_loaned_token();

        fvm.roll(200000);
    }

    function scenario_dee_has_a_token_2() public payable returns (uint160 tokenId) {
        tokenId = 2400;
        nuggft_call(dee, mint(tokenId));
    }

    function scenario_charlie_has_a_token() public payable returns (uint160 tokenId) {
        tokenId = 2070;
        nuggft_call(charlie, mint(tokenId));
    }

    function scenario_migrator_set() public payable {
        nuggft_call(safe, setMigrator(address(migrator)));
    }

    function scenario_dee_has_a_token_and_can_swap() public payable returns (uint160 tokenId) {
        tokenId = scenario_dee_has_a_token();

        nuggft_call(dee, approve(address(nuggft), tokenId));
    }

    function scenario_dee_has_swapped_a_token() public payable returns (uint160 tokenId, uint96 floor) {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        floor = 1 ether;

        nuggft_call(dee, swap(tokenId, floor));
    }

    function scenario_dee_has_swapped_a_token_and_mac_has_delegated() public payable returns (uint160 tokenId, uint96 eth) {
        (tokenId, ) = scenario_dee_has_swapped_a_token();

        eth = 2 ether;

        nuggft_call(mac, delegate(address(mac), tokenId), eth);
    }

    function scenario_dee_has_swapped_a_token_and_mac_can_claim() public payable returns (uint160 tokenId) {
        (tokenId, ) = scenario_dee_has_swapped_a_token_and_mac_has_delegated();

        fvm.roll(2000);
    }

    function scenario_mac_has_claimed_a_token_dee_swapped() public payable returns (uint160 tokenId) {
        (tokenId) = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        nuggft_call(mac, claim(address(mac), tokenId));
    }

    function scenario_mac_has_swapped_a_token_dee_swapped() public payable returns (uint160 tokenId, uint96 floor) {
        (tokenId) = scenario_mac_has_claimed_a_token_dee_swapped();
        floor = 3 ether;

        nuggft_call(mac, approve(address(nuggft), tokenId));

        nuggft_call(mac, swap(tokenId, floor));
    }

    function scenario_dee_has_a_token_and_can_swap_an_item()
        public
        payable
        returns (
            uint160 tokenId,
            uint16 itemId,
            uint8 feature
        )
    {
        (tokenId) = scenario_dee_has_a_token();

        (, uint8[] memory items, , , ) = nuggft.parsedProofOf(tokenId);

        feature = 1;
        itemId = items[feature] | (uint16(feature) << 8);

        nuggft_call(dee, rotateFeature(tokenId, feature));
    }

    function scenario_dee_has_swapped_an_item()
        public
        payable
        returns (
            uint160 tokenId,
            uint8 feature,
            uint16 itemId,
            uint96 floor
        )
    {
        (tokenId, itemId, feature) = scenario_dee_has_a_token_and_can_swap_an_item();
        floor = 3 ether;

        nuggft_call(dee, swapItem(tokenId, itemId, floor));
    }

    function scenario_dee_has_swapped_an_item_and_charlie_can_claim()
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
        (tokenId, feature, itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        nuggft_call(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);

        fvm.roll(2000);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    // function environment() public returns (address[] memory users) {
    //     users = new address[](2000);

    //     User start = new User{value: 69 ether}();
    //     uint160 count = 501;

    //                 fvm.deal(address(start), 69 ether);

    //     nuggft_call(start, mint(count++), .01 ether);
    //     nuggft_call(start, mint(count++), nuggft.minSharePrice());
    //     nuggft_call(start, mint(count++), nuggft.minSharePrice());

    //     users[0] = address(start);

    //     for (uint256 i = 1; i < users.length; i++) {
    //         User tmp = new User{value: 69 ether}();

    //         fvm.deal(address(tmp), 69 ether);

    //         nuggft_call(tmp, mint(count++), nuggft.minSharePrice());
    //         nuggft_call(tmp, mint(count++), nuggft.minSharePrice());
    //         nuggft_call(tmp, mint(count++), nuggft.minSharePrice());

    //         users[i] = address(tmp);
    //     }

    // }

    function environmentForge() public returns (address[] memory users) {
        users = new address[](9500);

        User start = new User{value: 1000000000 ether}();
        uint160 count = 501;

      //   fvm.deal(address(start), 10000 *10**18);

        nuggft_call(start, mint(count++), .08 ether);

        users[0] = address(start);

        int256 last = 0;
        int256 lastDiff = 0;

        for (uint256 i = 1; i < users.length; i++) {
            // User tmp = new User{value: 100000000 ether}();

            // fvm.deal(address(tmp), 10000 *10**18);

            nuggft_call(start, mint(count++), nuggft.minSharePrice());

            int256 curr = nuggft.minSharePrice().safeInt();

            users[i] = address(start);

            int256 diff =  curr-last;
            emit log_named_int('diff', curr - last);
            emit log_named_int('ldif', diff - lastDiff);

            emit log_named_uint('nuggft.activeEthPerShare()', nuggft.activeEthPerShare());
            // emit log_named_uint('nuggft.totalProtocolEth()', nuggft.totalProtocolEth());
            // emit log_named_uint('nuggft.totalStakedEth()', nuggft.totalStakedEth());
            emit log_named_uint('nuggft.totalStakedShares()', nuggft.totalStakedShares());
            emit log_named_uint('nuggft.minSharePrice()', nuggft.minSharePrice());

            emit log_string('--------');

            last = curr;
            lastDiff = diff;
        }
    }

    function environmentForge2() public returns (address[] memory users) {
        users = environmentForge();

        uint256 bn = 5000;

        // for (uint256 i = 0; i < 10000; i++) {
        //     uint256 epoch = nuggft.epoch();

        //     uint256 funner = uint256(keccak256(abi.encodePacked(epoch))) % 100;

        //     nuggft_call(User(payable(users[funner])), delegate(users[funner], epoch), nuggft.minSharePrice());

        //     fvm.roll(bn);

        //     bn += 70;

        //     nuggft_call(User(payable(users[funner])), claim(users[funner], epoch));
        // }

        assert(false);
    }
}

// Success: test__system1()

//   users length: 2000
//   nuggft.activeEthPerShare(): 36422938319266817
//   nuggft.totalProtocolEth(): 13721927850988207037
//   nuggft.totalStakedEth(): 254960568234867720007
//   nuggft.totalStakedShares(): 7000

// Success: test__system1()

//   users length: 2000
//   nuggft.activeEthPerShare(): .220269870602728762
//   nuggft.totalProtocolEth(): 105.652900187038601090
//   nuggft.totalStakedEth(): 3524.317929643660202576
//   nuggft.totalStakedShares(): 16000

// Success: test__system1()
// *10
//   users length: 2000
//   nuggft.activeEthPerShare():  .081046931383505748
//   nuggft.totalProtocolEth(): 36.036371675422002761
//   nuggft.totalStakedEth():  891.516245218563229016
//   nuggft.totalStakedShares(): 11000

//   users length: 2000
//   nuggft.activeEthPerShare():   .009923420616251655
//   nuggft.totalProtocolEth():  10.797105517187750828
//   nuggft.totalStakedEth():   109.157626778768205405
//   nuggft.totalStakedShares(): 11000

// Success: test__system1()

//   users length: 2000
//   nuggft.activeEthPerShare(): .023820112972809680
//   nuggft.totalProtocolEth(): 23.605706549631210195
//   nuggft.totalStakedEth(): 262.021242700906482643
//   nuggft.totalStakedShares(): 11000

// Success: test__system1()

//   users length: 2000
//   nuggft.activeEthPerShare(): 22283800801842573
//   nuggft.totalProtocolEth(): 12045486919914902312
//   nuggft.totalStakedEth(): 133702804811055442627
//   nuggft.totalStakedShares(): 6000

//   users length: 2000
//   nuggft.activeEthPerShare(): 1.124042581556443270
//   nuggft.totalProtocolEth(): 658.232592803322633239
//   nuggft.totalStakedEth(): 7306.276780116881258328
//   nuggft.totalStakedShares(): 6500

// Success: test__system1()

//   users length: 2000
//   nuggft.activeEthPerShare(): .179846813049030914
//   nuggft.totalProtocolEth(): 105317214848531614175
//   nuggft.totalStakedEth(): 1169004284818700946598
//   nuggft.totalStakedShares(): 6500

// .092595956292375926

// .101719406217199627

// Success: test__system1()

//   users length: 2000
//   nuggft.activeEthPerShare(): .178270406414740660
//   nuggft.totalProtocolEth(): 96363895359319273644
//   nuggft.totalStakedEth(): 1069622438488443964472
//   nuggft.totalStakedShares(): 6000

// Success: test__system1()

//   users length: 1000
//   nuggft.activeEthPerShare():   1.425741271002990526
//   nuggft.totalProtocolEth():  305.518843786355111578
//   nuggft.totalStakedEth():   4277.223813008971579744
//   nuggft.totalStakedShares(): 3000
