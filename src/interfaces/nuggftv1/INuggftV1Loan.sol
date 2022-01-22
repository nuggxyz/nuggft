// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface INuggftV1Loan {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event Loan(uint160 indexed tokenId, bytes32 agency);

    event Rebalance(uint160 indexed tokenId, bytes32 agency);

    event Liquidate(uint160 indexed tokenId, bytes32 agency);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function rebalance(uint160 tokenId) external payable;

    function multirebalance(uint160[] memory tokenId) external payable;

    function loan(uint160 tokenId) external;

    function liquidate(uint160 tokenId) external payable;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice for a nugg's active loan: calculates the current min eth a user must send to liquidate or rebalance
    /// @dev contract ->
    /// @dev frontend -> used to set the amount of eth for user
    /// @param tokenId the token who's current loan to check
    /// @return isLoaned -> indicating if the token is loaned
    /// @return debt ->  the current amount loaned out, plus the final rebalance fee
    /// @return fee ->  the fee a user must pay to rebalance (and extend) the loan on their nugg
    /// @return earned -> the amount of eth the minSharePrice has increased since loan was last rebalanced
    /// @return insolventEpoch -> the epoch the loan becomes insolvent
    function loanInfo(uint160 tokenId)
        external
        view
        returns (
            bool isLoaned,
            uint96 debt,
            uint96 fee,
            uint96 earned,
            uint24 insolventEpoch
        );

    /// @notice "toLiquidate" value from "loanInfo"
    /// @dev should be used to tell user how much eth to send for liquidate
    function valueForLiquidate(uint160 tokenId) external view returns (uint96 res);

    /// @notice "toRebalance" value from "loanInfo"
    /// @dev should be used to tell user how much eth to send for rebalance
    function valueForRebalance(uint160 tokenId) external view returns (uint96 res);
}
