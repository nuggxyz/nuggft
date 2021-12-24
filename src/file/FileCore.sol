// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IdotnuggV1Data} from '../interfaces/IdotnuggV1.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SSTORE2} from '../libraries/SSTORE2.sol';

import {File} from './FileStorage.sol';
import {FilePure} from './FilePure.sol';


library FileCore {
    using FilePure for uint256;
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function storeFiles(
        uint8 feature,
        uint256[][] calldata data
    ) internal {

        uint8 len = data.length.safe8();

        require(len > 0, 'F:0');

        address ptr = SSTORE2.write(abi.encode(data));

        File.spointer().ptrs[feature].push(uint168(uint160(ptr)) | (uint168(len) << 160));

        uint256 cache = File.spointer().lengthData;

        uint8[] memory lengths = FilePure.getLengths(cache);

        lengths[feature] += len;

        File.spointer().lengthData = FilePure.setLengths(cache, lengths);
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

        uint8 totalLength = FilePure.getLengths(File.spointer().lengthData)[feature];

        require(pos < totalLength, 'F:2');

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

        require(store != address(0), 'F:3');

        data = abi.decode(SSTORE2.read(address(uint160(store))), (uint256[][]))[storePos];
    }
}
