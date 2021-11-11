// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

library EpochMath {
    struct State {
        uint256 genesisBlock;
        uint8 interval;
    }

    enum Status {
        OVER,
        ACTIVE,
        PENDING
    }

    struct Epoch {
        uint256 id;
        uint256 startblock;
        uint256 endblock;
        Status status;
    }

    function getEpoch(
        EpochMath.State memory state,
        uint256 id,
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
        State memory state,
        uint256 id,
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
    function getStartBlockFromId(State memory state, uint256 id) internal pure returns (uint256 res) {
        res = id * state.interval + state.genesisBlock;
    }

    /**
     * @dev #TODO
     * @return res
     */
    function getEndBlockFromId(State memory state, uint256 id) internal pure returns (uint256 res) {
        res = getStartBlockFromId(state, id + 1) - 1;
    }

    function getIdFromBlocknum(State memory state, uint256 blocknum) internal pure returns (uint256 res) {
        res = (blocknum - state.genesisBlock) / state.interval;
    }
}
