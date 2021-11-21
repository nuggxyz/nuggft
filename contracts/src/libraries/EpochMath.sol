// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

library EpochMath {
    enum Status {
        OVER,
        ACTIVE,
        PENDING
    }

    struct Epoch {
        uint48 id;
        uint256 startblock;
        uint256 endblock;
        Status status;
    }

    function encodeData(uint128 _interval, uint128 _baseblock) internal pure returns (uint256 res) {
        assembly {
            res := or(shl(128, _baseblock), _interval)
        }
    }

    function decodeGenesis() internal pure returns (uint256 res) {
        assembly {
            res := 0
        }
    }

    function decodeInterval() internal pure returns (uint256 res) {
        assembly {
            res := 25
        }
    }

    function getEpoch(uint48 id, uint256 blocknum) internal pure returns (EpochMath.Epoch memory res) {
        res = EpochMath.Epoch({
            id: id,
            startblock: getStartBlockFromId(id),
            endblock: getEndBlockFromId(id),
            status: getStatus(id, blocknum)
        });
    }

    function getStatus(uint48 id, uint256 blocknum) internal pure returns (Status res) {
        if (getIdFromBlocknum(blocknum) == id) res = Status.ACTIVE;
        else if (getEndBlockFromId(id) < blocknum) res = Status.OVER;
        else res = Status.PENDING;
    }

    /**
     * @dev #TODO
     * @return res
     */
    function getStartBlockFromId(uint48 id) internal pure returns (uint256 res) {
        res = id * decodeInterval() + decodeGenesis();
    }

    /**
     * @dev #TODO
     * @return res
     */
    function getEndBlockFromId(uint48 id) internal pure returns (uint256 res) {
        res = getStartBlockFromId(id + 1) - 1;
    }

    function getIdFromBlocknum(uint256 blocknum) internal pure returns (uint48 res) {
        res = uint48((blocknum - decodeGenesis()) / decodeInterval());
    }
}
