// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

library EpochMath {
    enum Status {
        OVER,
        ACTIVE,
        PENDING
    }

    struct Epoch {
        uint64 id;
        uint256 startblock;
        uint256 endblock;
        Status status;
    }

    function encodeData(uint128 _interval, uint128 _baseblock) internal pure returns (uint256 res) {
        assembly {
            res := or(shl(128, _baseblock), _interval)
        }
    }

    function decodeGenesis(uint256 _state) internal pure returns (uint256 res) {
        assembly {
            res := shr(128, _state)
        }
    }

    function decodeInterval(uint256 _state) internal pure returns (uint256 res) {
        assembly {
            res := shr(128, shl(128, _state))
        }
    }

    function getEpoch(
        uint256 state,
        uint64 id,
        uint256 blocknum
    ) internal pure returns (EpochMath.Epoch memory res) {
        res = EpochMath.Epoch({
            id: id,
            startblock: getStartBlockFromId(state, id),
            endblock: getEndBlockFromId(state, id),
            status: getStatus(state, id, blocknum)
        });
    }

    function getStatus(
        uint256 state,
        uint64 id,
        uint256 blocknum
    ) internal pure returns (Status res) {
        if (getIdFromBlocknum(state, blocknum) == id) res = Status.ACTIVE;
        else if (getEndBlockFromId(state, id) < blocknum) res = Status.OVER;
        else res = Status.PENDING;
    }

    /**
     * @dev #TODO
     * @return res
     */
    function getStartBlockFromId(uint256 state, uint64 id) internal pure returns (uint256 res) {
        res = id * decodeInterval(state) + decodeGenesis(state);
    }

    /**
     * @dev #TODO
     * @return res
     */
    function getEndBlockFromId(uint256 state, uint64 id) internal pure returns (uint256 res) {
        res = getStartBlockFromId(state, id + 1) - 1;
    }

    function getIdFromBlocknum(uint256 state, uint256 blocknum) internal pure returns (uint64 res) {
        res = uint64((blocknum - decodeGenesis(state)) / decodeInterval(state));
    }
}
