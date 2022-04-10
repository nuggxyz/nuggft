// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

// prettier-ignore

interface INuggftV1Swap {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param tokenId (uint160)
    /// @param agency  (bytes32) a parameter just like in doxygen (must be followed by parameter name)
    event Offer(uint160 indexed tokenId, bytes32 agency, bytes32 stake);

    event OfferMint(uint160 indexed tokenId, bytes32 agency, bytes32 proof, bytes32 stake);

    event Claim(uint160 indexed tokenId, address indexed account);

    event Sell(uint160 indexed tokenId, bytes32 agency);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function offer(uint160 tokenId) external payable;

    function claim(uint160[] calldata tokenIds, address[] calldata accounts) external;

    function sell(uint160 tokenId, uint96 floor) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice calculates the minimum eth that must be sent with a offer call
    /// @dev returns 0 if no offer can be made for this oken
    /// @param tokenId -> the token to be offerd to
    /// @param sender -> the address of the user who will be delegating
    /// @return canOffer -> instead of reverting this function will return false
    /// @return next -> the minimum value that must be sent with a offer call
    /// @return current ->
    function check(address sender, uint160 tokenId) external view
        returns (bool canOffer, uint96 next, uint96 current);

    function vfo(address sender, uint160 tokenId) external view returns (uint96 res);
}
