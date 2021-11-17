// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IStakeable.sol';
import '../libraries/StakeMath.sol';
import '../common/Testable.sol';
import '../common/Mutexable.sol';

/**
 * @title Stakeable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice implementable by other contracts to make them stakeable
//  * @dev overall value of reward per epoch is not kept track of - see StakeMath.sol for logic
 */
abstract contract Stakeable is IStakeable, Mutexable, Testable {
    using StakeMath for StakeMath.State;

    /*
     * @dev two aggregate values are kept track of:
     * 1. Total Shares (_supply): the total amount of user deposts, represting their percent share of the epoch pool
     * 2. Earnings Per Share (_shares): - the earnings per user invested wei
     **/
    uint256 internal _supply;
    uint256 internal _shares;

    /*
     * @dev keeps track of individual user info
     * shares: the amount a user has invested, also represents their share of total supply
     * earnings: used to properly weight eps based on when the user invested
     **/
    // mapping(address => uint256) internal _posShares;
    mapping(address => uint256) internal _shares_owned;

    modifier validateSupply() {
        _;
        require(getState().tSupply == address(this).balance, 'STAKE:TS:0');
    }

    constructor() {}

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function totalSupply() public view virtual override returns (uint256 res) {
        res = getState().tSupply;
    }

    /**
     * @dev in regards to this contract, this could just be earningsOf + sharesOf
     */
    function supplyOf(address account) public view override returns (uint256 res) {
        res = StakeMath.getBalance(getState(), getPosition(account));
    }

    function _supplyOfBefore(address account, uint256 amount) public view returns (uint256 res) {
        res = StakeMath.getBalance(getStateBeforeDeposit(amount), getPosition(account));
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function totalShares() public view override returns (uint256 res) {
        res = getState().rSupply;
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function sharesOf(address account) public view override returns (uint256 res) {
        res = _shares_owned[account];
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function ownershipOfX128(address account) public view override returns (uint256 res) {
        res = StakeMath.getOwnershipX128(getState(), getPosition(account));
    }

    /**
     * @dev external wrapper for _positions[account]
     */
    function getStateBeforeDeposit(uint256 amount) internal view returns (StakeMath.State memory res) {
        // res.tSupply = address(this).balance > 0 ? address(this).balance - amount : 0;
        res.tSupply = _supply;
        res.rSupply = _shares;
    }

    function getState() internal view returns (StakeMath.State memory res) {
        res.tSupply = _supply;
        res.rSupply = _shares;
    }

    function getPosition(address account) internal view returns (StakeMath.Position memory res) {
        res.rOwned = _shares_owned[account];
    }

    function setState(StakeMath.State memory update) internal {
        _shares = update.rSupply;
        _supply = update.tSupply;
    }

    function setPosition(StakeMath.Position memory update, address account) internal {
        _shares_owned[account] = update.rOwned;
    }

    /*
     *  LOGIC
     * * * * * */

    /**
     * @dev increases a users total staked shares in a given epoch
     * @param account the user who is adding shares
     * @param value the amount shares is being increased
     * @custom:assump earnings should stay same
     */
    function _onShareAdd(address account, uint256 value) internal {
        StakeMath.State memory state = getStateBeforeDeposit(value);
        StakeMath.Position memory pos = getPosition(account);

        uint256 shares = StakeMath.applyShareAdd(state, pos, value);

        setState(state);
        setPosition(pos, account);

        emit ShareAdd(account, shares, value);
    }

    function _onShareSub(address account, uint256 value) internal {
        StakeMath.State memory state = getState();
        StakeMath.Position memory pos = getPosition(account);

        uint256 shares = StakeMath.applyShareSub(state, pos, value);

        setState(state);
        setPosition(pos, account);

        emit ShareSub(account, shares, value);
    }

    function _onShareMove(
        address from,
        address to,
        uint256 value
    ) internal {
        StakeMath.State memory state = getState();
        StakeMath.Position memory posTo = getPosition(to);
        StakeMath.Position memory posFrom = getPosition(from);

        uint256 shares = StakeMath.applyShareMove(state, posFrom, posTo, value);

        setState(state);
        setPosition(posFrom, from);
        setPosition(posTo, to);

        emit ShareSub(from, shares, value);
        emit ShareAdd(to, shares, value);
    }

    /**
     * @notice increases the overall eps from an increase in total rewards
     * @param value the amount the total reward is being increased
     */
    function _onValueAdd(address from, uint256 value) internal virtual {
        // StakeMath.State memory state = getState();

        // StakeMath.applyValueAdd(state, amount);

        // setState(state);

        _supply += value;

        emit ValueAdd(from, value);
    }

    // function _onRealize(address account, uint256 amount) internal {
    //     emit Realize(account, msg_sender(), amount);
    // }
}
