pragma solidity 0.8.4;
import './INuggSwapable.sol';

interface INuggMintable is INuggSwapable {
    function mint() external;
}
