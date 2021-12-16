import {Global} from '../global/storage.sol';

library ProofView {
    function checkedProofOf(uint256 tokenId) internal view returns (uint256 res) {
        res = Global.ptr().proofs[tokenId];
        require(res != 0, 'PROOF:PO:0');
    }

    function checkedProofOfIncludingPending(uint256 tokenId) internal view returns (uint256 res) {
        if (tokenId == genesis().activeEpoch()) {
            (uint256 p, , , ) = ProofLib.pendingProof(Global.ptr());
            return p;
        }
        res = Global.ptr().proofs[tokenId];
        require(res != 0, 'PROOF:PO:0');
    }

    function hasProof(uint256 tokenId) internal view returns (bool res) {
        res = global._proofs[tokenId] != 0;
    }

    function parseProof(uint256 tokenId)
        internal
        view
        returns (
            uint256 proof,
            uint256[] memory defaultIds,
            uint256[] memory extraIds,
            uint256[] memory overrides
        )
    {
        proof = global._proofOf(tokenId);

        return ProofShiftLib.parseProofLogic(proof);

        // TODO HAVE TO IMPLEMENT OVERRIDES AND EXTRA IDS
        // defaultIds = new uint256[](8);

        // for (uint256 i = 1; i < 6; i++) {
        //     defaultIds[i] = (proof >> (4 + (ITEMID_SIZE * 6) + ITEMID_SIZE * (i - 1)));
        // }
    }

    function pendingProof(uint256 genesis)
        internal
        view
        returns (
            uint256 proof,
            uint256[] memory defaultIds,
            uint256[] memory extraIds,
            uint256[] memory overrides
        )
    {
        (uint256 seed, ) = EpochLib.calculateSeed(genesis);

        uint256 lendata = global._vault.lengthData;

        seed = ProofShiftLib.initFromSeed(lendata, seed);

        return ProofShiftLib.parseProofLogic(seed);
    }
}
