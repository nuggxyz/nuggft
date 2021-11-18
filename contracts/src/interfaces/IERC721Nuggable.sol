pragma solidity 0.8.4;
import './INuggSwapable.sol';

interface IERC721Nuggable is INuggSwapable {
    function nsMint(uint256 currentEpochId) external returns (uint256 tokenId);

    function epochToTokenId(uint256 epoch) external returns (uint256 tokenId);
}
