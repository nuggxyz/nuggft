// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface INuggftV1Loan {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event TakeLoan(uint160 tokenId, uint96 principal);
    event Payoff(uint160 tokenId, address account, uint96 payoffAmount);
    event Rebalance(uint160 tokenId, uint96 fee, uint96 earned);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function rebalance(uint160 tokenId) external payable;

    function loan(uint160 tokenId) external;

    function payoff(uint160 tokenId) external payable;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice for a nugg's active loan: calculates the current min eth a user must send to payoff or rebalance
    /// @dev contract ->
    /// @dev frontend -> used to set the amount of eth for user
    /// @param tokenId the token who's current loan to check
    /// @return toPayoff ->  the current amount loaned out, plus the final rebalance fee
    /// @return toRebalance ->  the fee a user must pay to rebalance (and extend) the loan on their nugg
    /// @return earned -> the amount of eth the minSharePrice has increased since loan was last rebalanced
    /// @return epochDue -> the final epoch a user is safe from liquidation (inclusive)
    /// @return loaner -> the user responsable for the loan
    function loanInfo(uint160 tokenId)
        external
        view
        returns (
            uint96 toPayoff,
            uint96 toRebalance,
            uint96 earned,
            uint32 epochDue,
            address loaner
        );

    /// @notice "toPayoff" value from "loanInfo"
    /// @dev should be used to tell user how much eth to send for payoff
    function valueForPayoff(uint160 tokenId) external view returns (uint96 res);

    /// @notice "toRebalance" value from "loanInfo"
    /// @dev should be used to tell user how much eth to send for rebalance
    function valueForRebalance(uint160 tokenId) external view returns (uint96 res);
}
