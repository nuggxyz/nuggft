// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC2981Receiver.sol';

/**
 * @dev Implementation of the {IERC2981Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC2981-safeTransferFrom}, {IERC2981-approve} or {IERC2981-setApprovalForAll}.
 */
contract ERC2981Receiver is IERC2981Receiver {
    /**
     * @dev See {IERC2981Receiver-onERC2981Received}.
     *
     * Always returns `IERC2981Receiver.onERC2981Received.selector`.
     */
    function onERC2981Received(
        address operator,
        address from,
        address token,
        uint256 tokenId,
        address erc20,
        uint256 amount,
        bytes calldata data
    ) public payable virtual override returns (bytes4) {
        return this.onERC2981Received.selector;
    }
}
