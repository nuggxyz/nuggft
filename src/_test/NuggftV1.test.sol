// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from './utils/DSTestPlus.sol';

import './utils/User.sol';

import {IDotnuggV1Metadata} from '../interfaces/dotnuggv1/IDotnuggV1Metadata.sol';

import {MockDotnuggV1} from './mock/MockDotnuggV1.sol';

import {MockNuggftV1Migrator} from './mock/MockNuggftV1Migrator.sol';

import {NuggftV1} from '../NuggftV1.sol';

import './utils/logger.sol';

contract RiggedNuggft is NuggftV1 {
    constructor(address[] memory trusted) NuggftV1(trusted, address(this)) {
        featureLengths = 0x0303030303030303;
    }

    function getBlockHash(uint256 blocknum) internal view override returns (bytes32 res) {
        if (block.number >= blocknum && block.number - blocknum < 256) {
            return keccak256(abi.encodePacked(blocknum));
        }
    }

    function external__calculateSeed() external view returns (uint256 res, uint24 _epoch) {
        return calculateSeed();
    }

    function external__calculateSeed(uint24 epoch) external view returns (uint256 res) {
        return calculateSeed(epoch);
    }
}

library SafeCast {
    function safeInt(uint96 input) internal pure returns (int192) {
        return (int192(int256(uint256(input))));
    }
}

contract NuggftV1Test is t {
    using SafeCast for uint96;
    using SafeCast for uint256;
    using SafeCast for uint64;

    using UserTarget for address;

    MockDotnuggV1 public processor;

    MockNuggftV1Migrator public migrator;

    RiggedNuggft public nuggft;

    address public _nuggft;

    User public safe;

    User public frank;
    User public charlie;
    User public dennis;
    User public mac;
    User public dee;

    User public any;

    struct Users {
        address frank;
        address dee;
        address mac;
        address dennis;
        address charlie;
        address safe;
    }

    Users public users;

    constructor() {}

    function reset() public {
        fvm.roll(1000001);
        processor = new MockDotnuggV1();
        migrator = new MockNuggftV1Migrator();

        address[] memory trusted = new address[](1);
        trusted[0] = address(this);
        nuggft = new RiggedNuggft(trusted);
        _nuggft = address(nuggft);
        safe = new User();

        frank = new User();
        charlie = new User();
        dennis = new User();
        mac = new User();
        dee = new User();

        users.frank = fvm.addr(12);
        fvm.deal(users.frank, 90000 ether);

        users.dee = fvm.addr(13);
        fvm.deal(users.dee, 90000 ether);

        users.mac = fvm.addr(14);
        fvm.deal(users.mac, 90000 ether);

        users.dennis = fvm.addr(15);
        fvm.deal(users.dennis, 90000 ether);

        users.charlie = fvm.addr(16);
        fvm.deal(users.charlie, 90000 ether);

        users.safe = fvm.addr(17);
        fvm.deal(users.safe, 90000 ether);

        // any = new User();

        fvm.deal(address(safe), 30 ether);
        fvm.deal(address(dennis), 30 ether);
        fvm.deal(address(mac), 30 ether);
        fvm.deal(address(dee), 30 ether);
        fvm.deal(address(frank), 90000 ether);
        fvm.deal(address(charlie), 30 ether);

        nuggft.setIsTrusted(address(safe), true);
        nuggft.setIsTrusted(users.safe, true);
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
        str.before_staked = nuggft.stakedEth().safeInt();
        str.before_protocol = nuggft.protocolEth().safeInt();
        str.before_shares = nuggft.stakedShares().safeInt();
        str.before_minSharePrice = nuggft.minSharePrice().safeInt();

        str.before_eps = nuggft.ethPerShare().safeInt();

        assertEq(
            str.before_eps,
            str.before_shares > 0 ? str.before_staked / str.before_shares : int256(0),
            'EPS is starting off with an incorrect value'
        );

        _;
        str.after_staked = nuggft.stakedEth().safeInt();
        str.after_protocol = nuggft.protocolEth().safeInt();
        str.after_shares = nuggft.stakedShares().safeInt();
        str.after_minSharePrice = nuggft.minSharePrice().safeInt();

        assertTrue(str.after_minSharePrice >= str.before_minSharePrice, 'minSharePrice is did not increase as expected');
        assertEq(str.after_protocol - str.before_protocol, take(10, change), 'totalProtocol is not what is expected');
        assertEq(str.after_staked - str.before_staked, change - take(10, change), 'staked change is not 90 percent of expected change');
        assertEq(str.after_shares - str.before_shares, shareChange, 'shares difference is not what is expected');

        str.after_eps = nuggft.ethPerShare().safeInt();
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

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                encodeWithSelector
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function delegate(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.delegate.selector, tokenId);
    }

    function delegateItem(
        uint256 buyerTokenId,
        uint256 sellerTokenId,
        uint256 itemId
    ) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.delegateItem.selector, buyerTokenId, sellerTokenId, itemId);
    }

    function claim(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.claim.selector, tokenId);
    }

    function swap(uint256 tokenId, uint96 floor) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.swap.selector, tokenId, floor);
    }

    function loan(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.loan.selector, tokenId);
    }

    function liquidate(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.liquidate.selector, tokenId);
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

    function rotate(
        uint256 tokenId,
        uint8 index0,
        uint8 index1
    ) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.rotate.selector, tokenId, index0, index1);
    }

    function burn(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.burn.selector, tokenId);
    }

    function migrate(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.migrate.selector, tokenId);
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
        _nuggft.shouldPass(dee, mint(tokenId));
    }

    function scenario_frank_has_a_token_and_spent_50_eth() public payable returns (uint160 tokenId) {
        tokenId = 2012;
        _nuggft.shouldPass(frank, mint(tokenId), 50 ether);
    }

    function scenario_frank_has_a_loaned_token() public payable returns (uint160 tokenId) {
        scenario_charlie_has_a_token();

        tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        {
            _nuggft.shouldPass(frank, approve(address(nuggft), tokenId));
        }

        _nuggft.shouldPass(frank, loan(tokenId));
    }

    function scenario_frank_has_a_loaned_token_that_has_expired() public payable returns (uint160 tokenId) {
        tokenId = scenario_frank_has_a_loaned_token();

        fvm.roll(200000);
    }

    function scenario_dee_has_a_token_2() public payable returns (uint160 tokenId) {
        tokenId = 2400;
        _nuggft.shouldPass(dee, mint(tokenId));
    }

    function scenario_charlie_has_a_token() public payable returns (uint160 tokenId) {
        tokenId = 2070;
        _nuggft.shouldPass(charlie, mint(tokenId));
    }

    function scenario_migrator_set() public payable {
        _nuggft.shouldPass(safe, setMigrator(address(migrator)));
    }

    function scenario_dee_has_a_token_and_can_swap() public payable returns (uint160 tokenId) {
        tokenId = scenario_dee_has_a_token();

        _nuggft.shouldPass(dee, approve(address(nuggft), tokenId));
    }

    function scenario_dee_has_swapped_a_token() public payable returns (uint160 tokenId, uint96 floor) {
        tokenId = scenario_dee_has_a_token_and_can_swap();

        floor = 1 ether;

        _nuggft.shouldPass(dee, swap(tokenId, floor));
    }

    function scenario_dee_has_swapped_a_token_and_mac_has_delegated() public payable returns (uint160 tokenId, uint96 eth) {
        (tokenId, ) = scenario_dee_has_swapped_a_token();

        eth = 2 ether;

        _nuggft.shouldPass(mac, delegate(tokenId), eth);
    }

    function scenario_dee_has_swapped_a_token_and_mac_can_claim() public payable returns (uint160 tokenId) {
        (tokenId, ) = scenario_dee_has_swapped_a_token_and_mac_has_delegated();

        fvm.roll(2000);
    }

    function scenario_mac_has_claimed_a_token_dee_swapped() public payable returns (uint160 tokenId) {
        (tokenId) = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        _nuggft.shouldPass(mac, claim(tokenId));
    }

    function scenario_mac_has_swapped_a_token_dee_swapped() public payable returns (uint160 tokenId, uint96 floor) {
        (tokenId) = scenario_mac_has_claimed_a_token_dee_swapped();
        floor = 3 ether;

        _nuggft.shouldPass(mac, approve(address(nuggft), tokenId));

        _nuggft.shouldPass(mac, swap(tokenId, floor));
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

        _nuggft.shouldPass(dee, swapItem(tokenId, itemId, floor));
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

        _nuggft.shouldPass(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);

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

        _nuggft.shouldPass(start, mint(count++), .08 ether);

        users[0] = address(start);

        int256 last = 0;
        int256 lastDiff = 0;

        for (uint256 i = 1; i < users.length; i++) {
            // User tmp = new User{value: 100000000 ether}();

            // fvm.deal(address(tmp), 10000 *10**18);

            _nuggft.shouldPass(start, mint(count++), nuggft.minSharePrice());

            int256 curr = nuggft.minSharePrice().safeInt();

            users[i] = address(start);

            int256 diff = curr - last;
            emit log_named_int('diff', curr - last);
            emit log_named_int('ldif', diff - lastDiff);

            emit log_named_uint('nuggft.ethPerShare()', nuggft.ethPerShare());
            // emit log_named_uint('nuggft.protocolEth()', nuggft.protocolEth());
            // emit log_named_uint('nuggft.stakedEth()', nuggft.stakedEth());
            emit log_named_uint('nuggft.stakedShares()', nuggft.stakedShares());
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
//   nuggft.ethPerShare(): 36422938319266817
//   nuggft.protocolEth(): 13721927850988207037
//   nuggft.stakedEth(): 254960568234867720007
//   nuggft.stakedShares(): 7000

// Success: test__system1()

//   users length: 2000
//   nuggft.ethPerShare(): .220269870602728762
//   nuggft.protocolEth(): 105.652900187038601090
//   nuggft.stakedEth(): 3524.317929643660202576
//   nuggft.stakedShares(): 16000

// Success: test__system1()
// *10
//   users length: 2000
//   nuggft.ethPerShare():  .081046931383505748
//   nuggft.protocolEth(): 36.036371675422002761
//   nuggft.stakedEth():  891.516245218563229016
//   nuggft.stakedShares(): 11000

//   users length: 2000
//   nuggft.ethPerShare():   .009923420616251655
//   nuggft.protocolEth():  10.797105517187750828
//   nuggft.stakedEth():   109.157626778768205405
//   nuggft.stakedShares(): 11000

// Success: test__system1()

//   users length: 2000
//   nuggft.ethPerShare(): .023820112972809680
//   nuggft.protocolEth(): 23.605706549631210195
//   nuggft.stakedEth(): 262.021242700906482643
//   nuggft.stakedShares(): 11000

// Success: test__system1()

//   users length: 2000
//   nuggft.ethPerShare(): 22283800801842573
//   nuggft.protocolEth(): 12045486919914902312
//   nuggft.stakedEth(): 133702804811055442627
//   nuggft.stakedShares(): 6000

//   users length: 2000
//   nuggft.ethPerShare(): 1.124042581556443270
//   nuggft.protocolEth(): 658.232592803322633239
//   nuggft.stakedEth(): 7306.276780116881258328
//   nuggft.stakedShares(): 6500

// Success: test__system1()

//   users length: 2000
//   nuggft.ethPerShare(): .179846813049030914
//   nuggft.protocolEth(): 105317214848531614175
//   nuggft.stakedEth(): 1169004284818700946598
//   nuggft.stakedShares(): 6500

// .092595956292375926

// .101719406217199627

// Success: test__system1()

//   users length: 2000
//   nuggft.ethPerShare(): .178270406414740660
//   nuggft.protocolEth(): 96363895359319273644
//   nuggft.stakedEth(): 1069622438488443964472
//   nuggft.stakedShares(): 6000

// Success: test__system1()

//   users length: 1000
//   nuggft.ethPerShare():   1.425741271002990526
//   nuggft.protocolEth():  305.518843786355111578
//   nuggft.stakedEth():   4277.223813008971579744
//   nuggft.stakedShares(): 3000
