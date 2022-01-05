// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Metadata as Metadata} from './IDotnuggV1Metadata.sol';
import {IDotnuggV1File as File} from './IDotnuggV1File.sol';
import {IDotnuggV1Storage} from './IDotnuggV1Storage.sol';

interface IDotnuggV1 is IDotnuggV1Storage {
    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                core processors
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function dotnuggToRaw(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes calldata data
    ) external view returns (File.Raw memory res);

    function dotnuggToProcessed(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes calldata data
    ) external view returns (File.Processed memory res);

    function dotnuggToCompressed(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes calldata data
    ) external view returns (File.Compressed memory res);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            basic resolved processors
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function dotnuggToBytes(
        address implementer,
        uint256 id,
        address resolver,
        bytes calldata data
    ) external view returns (bytes memory res);

    function dotnuggToString(
        address implementer,
        uint256 id,
        address resolver,
        bytes calldata data
    ) external view returns (string memory res);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            complex resolved processors
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function dotnuggToJson(
        address implementer,
        uint256 id,
        address resolver,
        bytes calldata data
    ) external view returns (string memory res);

    function dotnuggToSvg(
        address implementer,
        uint256 id,
        address resolver,
        uint8 zoom,
        bool rekt,
        bool background,
        bool base64,
        bool stats,
        bytes calldata data
    ) external view returns (string memory res);
}
