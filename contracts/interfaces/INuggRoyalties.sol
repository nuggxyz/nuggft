pragma solidity 0.8.4;

import '../erc2981/IERC2981.sol';

interface INuggRoyalties is IERC2981 {
    function mint() external;
}
