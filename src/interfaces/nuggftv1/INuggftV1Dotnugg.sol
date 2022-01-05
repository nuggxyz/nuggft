// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Implementer} from '../dotnuggv1/IDotnuggV1Implementer.sol';

interface INuggftV1Dotnugg is IDotnuggV1Implementer {
    event DotnuggV1ResolverUpdated(uint256 tokenId, address to);

    function setDotnuggV1Resolver(uint256 tokenId, address to) external;

    function dotnuggV1ResolverOf(uint256 tokenId) external view returns (address resolver);

    function dotnuggV1() external returns (address);

    function setDotnuggV1AnchorOverrides(
        uint160 tokenId,
        uint16 itemId,
        uint256 x,
        uint256 y
    ) external;

    function setDotnuggV1Background(uint160 tokenId, string memory s) external;

    function setDotnuggV1Style(
        uint160 tokenId,
        uint16 itemId,
        string memory s
    ) external;
}
