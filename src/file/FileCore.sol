// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IdotnuggV1Data} from '../interfaces/IdotnuggV1.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SSTORE2} from '../libraries/SSTORE2.sol';

import {File} from './FileStorage.sol';
import {FilePure} from './FilePure.sol';
import {FileView} from './FileView.sol';
import {ProofPure} from '../proof/ProofPure.sol';
import {ProofView} from '../proof/ProofView.sol';

import {TokenView} from '../token/TokenView.sol';

import {Trust} from '../trust/TrustStorage.sol';

library FileCore {
    using FilePure for uint256;
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                PROCESS FILES
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function prepareForProcess(
        uint160 tokenId,
        uint8 zoom,
        uint8 size
    ) internal view returns (uint256[][] memory files, IdotnuggV1Data.Data memory data) {
        (uint256 proof, uint8[] memory ids, uint8[] memory extras, uint8[] memory xovers, uint8[] memory yovers) = ProofView
            .parsedProofOfIncludingPending(tokenId);

        files = FileCore.getBatchFiles(ids);

        data = IdotnuggV1Data.Data({
            version: 1,
            zoom: zoom,
            size: size,
            renderedAt: block.timestamp,
            name: 'NuggFT V1',
            desc: 'Nugg Fungible Token V1 by nugg.xyz',
            owner: TokenView.ownerOf(tokenId),
            tokenId: tokenId,
            proof: proof,
            ids: ids,
            extras: extras,
            xovers: xovers,
            yovers: yovers
        });
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                RESOLVER SET
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function setResolver(uint160 tokenId, address to) internal {
        require(TokenView.isApprovedOrOwner(msg.sender, tokenId), 'T:0');

        File.spointer().resolvers[tokenId] = to;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function trustedStoreFiles(
        Trust.Storage storage trust,
        uint8 feature,
        uint256[][] calldata data
    ) internal {
        require(trust._isTrusted, 'T:0');

        uint8 len = data.length.safe8();

        require(len > 0, 'VC:0');

        uint168 working = uint168(len) << 160;

        address ptr = SSTORE2.write(abi.encode(data));

        File.spointer().ptrs[feature].push(uint168(uint160(ptr)) | working);

        uint256 cache = File.spointer().lengthData;

        uint8[] memory lengths = FilePure.getLengths(cache);

        lengths[feature] += len;

        File.spointer().lengthData = FilePure.setLengths(cache, lengths);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 GET FILES
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function getBatchFiles(uint8[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint8 i = 0; i < ids.length; i++) {
            if (ids[i] == 0) data[i] = new uint256[](0);
            else data[i] = get(i, ids[i]);
        }
    }

    function get(uint8 feature, uint8 pos) internal view returns (uint256[] memory data) {
        require(pos != 0, 'VC:2');

        pos--;

        uint8 totalLength = FilePure.getLengths(File.spointer().lengthData)[feature];

        require(pos < totalLength, 'VC:1');

        uint168[] memory ptrs = File.spointer().ptrs[feature];

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

        require(store != address(0), 'VC:2');

        data = abi.decode(SSTORE2.read(address(uint160(store))), (uint256[][]))[storePos];
    }
}
