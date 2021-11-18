// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './interfaces/IxNUGG.sol';
import './erc20/ERC20.sol';
import './libraries/Address.sol';
import './libraries/StakeMath.sol';

/**
 * @title xNUGG
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice leggo
 */
contract xNUGG is IxNUGG, ERC20 {
    using Address for address payable;
    using StakeMath for uint256;
    using StakeMath for StakeMath.State;

    address payable public tummy;

    uint256 internal _state;

    mapping(address => uint256) internal _shares_owned;

    constructor() ERC20('Staked NUGG', 'xNUGG') {
        tummy = payable(msg.sender);
    }

    receive() external payable {
        _recieve();
    }

    fallback() external payable {
        _recieve();
    }

    function mint() external payable override {
        _mint(msg.sender, msg.value);
    }

    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
    }

    /**
     * @dev in regards to this contract, this could just be earningsOf + sharesOf
     */
    function totalSupply() public view virtual override(ERC20, IxNUGG) returns (uint256 res) {
        res = _state.decodeState().tSupply;
    }

    /**
     * @dev in regards to this contract, this could just be earningsOf + sharesOf
     */
    function balanceOf(address account) public view override(ERC20, IxNUGG) returns (uint256 res) {
        res = _state.decodeState().getBalance(StakeMath.Position(_shares_owned[account]));
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function totalShares() public view override returns (uint256 res) {
        res = _state.decodeState().rSupply;
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function sharesOf(address account) public view override returns (uint256 res) {
        res = _shares_owned[account];
    }

    function ownershipOfX128(address account) public view override returns (uint256 res) {
        res = _state.decodeState().getOwnershipX128(StakeMath.Position(_shares_owned[account]));
    }

    function _recieve() internal {
        if (msg.value > 0) {
            uint256 t = (msg.value * 100) / 1000;
            onValueAdd(msg.sender, msg.value - t);
            tummy.sendValue(t);
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        onShareMove(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal override {
        onShareAdd(account, amount);
    }

    function _burn(address account, uint256 amount) internal override {
        onShareSub(account, amount);
        payable(account).sendValue(amount);
    }

    /**
     * @dev increases a users total staked shares in a given epoch
     * @param account the user who is adding shares
     * @param value the amount shares is being increased
     * @custom:assump earnings should stay same
     */
    function onShareAdd(address account, uint256 value) internal {
        StakeMath.State memory state = _state.decodeState();
        StakeMath.Position memory pos = StakeMath.Position(_shares_owned[account]);

        uint256 shares = state.applyShareAdd(pos, value);

        _state = state.encodeState();
        _shares_owned[account] = pos.rOwned;

        emit ShareAdd(account, shares, value);
    }

    function onShareSub(address account, uint256 value) internal {
        StakeMath.State memory state = _state.decodeState();
        StakeMath.Position memory pos = StakeMath.Position(_shares_owned[account]);

        uint256 shares = state.applyShareSub(pos, value);

        _state = state.encodeState();
        _shares_owned[account] = pos.rOwned;

        emit ShareSub(account, shares, value);
    }

    function onShareMove(
        address from,
        address to,
        uint256 value
    ) internal {
        StakeMath.State memory state = _state.decodeState();
        StakeMath.Position memory posFrom = StakeMath.Position(_shares_owned[from]);
        StakeMath.Position memory posTo = StakeMath.Position(_shares_owned[to]);

        uint256 shares = state.applyShareMove(posFrom, posTo, value);

        _shares_owned[from] = posFrom.rOwned;
        _shares_owned[to] = posTo.rOwned;

        emit ShareSub(from, shares, value);
        emit ShareAdd(to, shares, value);
    }

    /**
     * @notice increases the overall eps from an increase in total rewards
     * @param value the amount the total reward is being increased
     */
    function onValueAdd(address from, uint256 value) internal virtual {
        StakeMath.State memory state = _state.decodeState();

        state.applyValueAdd(value);

        _state = state.encodeState();

        emit ValueAdd(from, value);
    }
}
