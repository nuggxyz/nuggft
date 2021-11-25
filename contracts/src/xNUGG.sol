// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';

import './interfaces/IxNUGG.sol';

import './libraries/StakeLib.sol';
import './libraries/EpochLib.sol';

/**
 * @title xNUGG
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice leggo
 */
contract xNUGG is IxNUGG, ERC20 {
    using Address for address payable;
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
        emit Receive(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Receive(msg.sender, msg.value);
    }

    function mint() external payable override {
        uint256 mintedShares = StakeLib.add(msg.sender, msg.value);

        genesis.setSeed();

        emit Transfer(address(0), msg.sender, mintedShares);
    }

    function burn(uint256 eth) external override {
        uint256 burnedShares = StakeLib.sub(msg.sender, eth);

        genesis.setSeed();

        payable(msg.sender).sendValue(eth);

        emit Transfer(msg.sender, address(0), burnedShares);
    }

    function _transfer(
        address from,
        address to,
        uint256 eth
    ) internal override {
        uint256 movedShares = StakeLib.move(from, to, eth);

        genesis.setSeed();

        emit Transfer(from, to, movedShares);
    }

    /**
     * @dev in regards to this contract, this could just be earningsOf + sharesOf
     */
    function totalSupply() public view virtual override(ERC20, IxNUGG) returns (uint256 res) {
        res = StakeLib.getActiveShares();
    }

    /**
     * @dev in regards to this contract, this could just be earningsOf + sharesOf
     */
    function balanceOf(address account) public view override(ERC20, IxNUGG) returns (uint256 res) {
        res = account.getActiveSharesOf();
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function totalEth() public view override returns (uint256 res) {
        res = StakeLib.getActiveEth();
    }

    /**
     * @dev external wrapper for _shares - to save on gas
     */
    function ethOf(address account) public view override returns (uint256 res) {
        res = account.getActiveEthOf();
    }

    function ownershipOf(address account) public view override returns (uint256 res) {
        res = account.getActiveOwnershipOf();
    }
}
