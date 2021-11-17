// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC2981 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC2981 asset contracts.
 */
interface IERC2981Receiver {
    /**
     * @dev Whenever an {IERC2981} `tokenId` token is transferred to this contract via {IERC2981-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC2981.onERC2981Received.selector`.
     */
    function onERC2981Received(
        address operator,
        address from,
        address token,
        uint256 tokenId,
        address erc20,
        uint256 amount,
        bytes calldata data
    ) external payable returns (bytes4);
}
