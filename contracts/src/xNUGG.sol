// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './interfaces/IxNUGG.sol';
import './erc20/ERC20.sol';
import './libraries/Address.sol';
import './libraries/StakeLib.sol';
import './libraries/EpochLib.sol';

/**
 * @title xNUGG
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice leggo
 */
contract xNUGG is IxNUGG, ERC20 {
    using Address for address;
    using StakeLib for address;

    using EpochLib for uint256;

    uint256 public immutable override genesis;

    constructor() ERC20('Staked NUGG', 'xNUGG') {
        genesis = block.number;
    }

    function epoch() external view override returns (uint256 res) {
        return genesis.activeEpoch();
    }

    receive() external payable {
        emit Take(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Take(msg.sender, msg.value);
    }

    function mint() external payable override {
        uint256 mintedShares = msg.sender.add(msg.value);
        emit Mint(msg.sender, mintedShares, msg.value);
        genesis.setSeed();
    }

    function burn(uint256 eth) external override {
        uint256 burnedShares = msg.sender.sub(eth);
        msg.sender.sendValue(eth);
        emit Burn(msg.sender, burnedShares, eth);
        genesis.setSeed();
    }

    function _transfer(
        address from,
        address to,
        uint256 eth
    ) internal override {
        uint256 movedShares = from.move(to, eth);
        emit Move(from, to, movedShares, eth);
        genesis.setSeed();
    }

    /**
     * @dev in regards to this contract, this could just be earningsOf + sharesOf
     */
    function totalSupply() public view virtual override(ERC20, IxNUGG) returns (uint256 res) {
        res = StakeLib.balance();
    }

    /**
     * @dev in regards to this contract, this could just be earningsOf + sharesOf
     */
    function balanceOf(address account) public view override(ERC20, IxNUGG) returns (uint256 res) {
        res = account.getActiveBalanceOf();
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function totalShares() public view override returns (uint256 res) {
        res = StakeLib.getActiveShares();
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function sharesOf(address account) public view override returns (uint256 res) {
        res = account.getActiveSharesOf();
    }

    function ownershipOf(address account) public view override returns (uint256 res) {
        res = account.getActiveOwnershipOf();
    }
}
