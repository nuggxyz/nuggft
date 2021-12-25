// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IdotnuggV1Processor} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Resolver} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Data} from '../interfaces/IdotnuggV1.sol';
import {IdotnuggV1Implementer} from '../interfaces/IdotnuggV1.sol';
import {IERC721Metadata} from '../interfaces/IERC721.sol';

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {INuggftV1File} from '../interfaces/nuggftv1/INuggftV1File.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {NuggftV1Token} from './NuggftV1Token.sol';

import {Trust} from './Trust.sol';

import {SSTORE2} from '../libraries/SSTORE2.sol';

abstract contract NuggftV1File is INuggftV1File, NuggftV1Token, Trust {
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    /// @inheritdoc IdotnuggV1Implementer
    address public override dotnuggV1Processor;

    /// @inheritdoc IdotnuggV1Implementer
    uint8 public override defaultWidth = 45;

    // / @inheritdoc IdotnuggV1Implementer
    uint8 public override defaultZoom = 10;

    mapping(uint8 => uint168[]) sstore2Pointers;
    // Mapping from token ID to owner address

    mapping(uint256 => address) resolvers;

    uint256 internal featureLengths;

    constructor(address _dotnuggV1Processor) {
        require(_dotnuggV1Processor != address(0), 'F:4');
        dotnuggV1Processor = _dotnuggV1Processor;
    }

    /// @inheritdoc INuggftV1File
    function storeFiles(uint256[][] calldata data, uint8 feature) external override requiresTrust {
        _storeFiles(feature, data);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            RESOLVER MANAGEMENT
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc IdotnuggV1Implementer
    function setResolver(uint256 tokenId, address to) public virtual override {
        require(_isOperatorForOwner(msg.sender, tokenId.safe160()), 'F:5');

        resolvers[tokenId] = to;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            MAIN FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
        uint160 safeTokenId = tokenId.safe160();

        address resolver = hasResolver(safeTokenId) ? resolverOf(safeTokenId) : dotnuggV1Processor;

        res = IdotnuggV1Processor(dotnuggV1Processor).dotnuggToString(address(this), tokenId, resolver, defaultWidth, defaultZoom);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                VIEW
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IdotnuggV1Implementer
    function resolverOf(uint256 tokenId) public view virtual override returns (address) {
        return resolverOf(tokenId.safe160());
    }

    function hasResolver(uint160 tokenId) internal view returns (bool) {
        return resolvers[tokenId] != address(0);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function _storeFiles(uint8 feature, uint256[][] calldata data) internal {
        uint8 len = data.length.safe8();

        require(len > 0, 'F:0');

        address ptr = SSTORE2.write(abi.encode(data));

        sstore2Pointers[feature].push(uint168(uint160(ptr)) | (uint168(len) << 160));

        uint256 cache = featureLengths;

        // featureLengthOf[feature] += len;

        uint8[] memory lengths = ShiftLib.getArray(cache, 0);

        lengths[feature] += len;

        featureLengths = ShiftLib.setArray(cache, 0, lengths);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 GET FILES
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function getBatchFiles(uint8[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint8 i = 0; i < ids.length; i++) {
            if (ids[i] == 0) data[i] = new uint256[](0);
            else data[i] = get(i, ids[i]);
        }
    }

    function get(uint8 feature, uint8 pos) internal view returns (uint256[] memory data) {
        require(pos != 0, 'F:1');

        pos--;

        uint8 totalLength = ShiftLib.getArray(featureLengths, 0)[feature];

        require(pos < totalLength, 'F:2');

        uint168[] memory ptrs = sstore2Pointers[feature];

        address store;
        uint8 storePos;

        uint8 workingPos;

        for (uint256 i = 0; i < ptrs.length; i++) {
            uint8 here = uint8(ptrs[i] >> 160);
            if (workingPos + here > pos) {
                store = address(uint160(ptrs[i]));
                storePos = pos - workingPos;
                break;
            } else {
                workingPos += here;
            }
        }

        require(store != address(0), 'F:3');

        data = abi.decode(SSTORE2.read(address(uint160(store))), (uint256[][]))[storePos];
    }
}
