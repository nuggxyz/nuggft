// SPDX-License-Identifier: MIT

import '../token/Token.sol';

import '../libraries/EpochLib.sol';

import './ProofType.sol';

library ProofLib {
    event SetProof(uint256 tokenId, uint256[] items); // CANGE
    event PopItem(uint256 tokenId, uint256 itemId);
    event PushItem(uint256 tokenId, uint256 itemId);
    event OpenSlot(uint256 tokenId);

    uint256 constant ITEMID_SIZE = 12;

    using ProofType for uint256;
    using Token for Token.Storage;

    function proofOf(Token.Storage storage nuggft, uint256 tokenId) internal view returns (uint256 res) {
        res = nuggft._proofs[tokenId];
        require(res != 0, 'PROOF:PO:0');
    }

    function hasProof(Token.Storage storage nuggft, uint256 tokenId) internal view returns (bool res) {
        res = nuggft._proofs[tokenId] != 0;
    }

    function parseProof(Token.Storage storage nuggft, uint256 tokenId)
        internal
        view
        returns (
            uint256 proof,
            uint256[] memory defaultIds,
            uint256[] memory extraIds,
            uint256[] memory overrides
        )
    {
        proof = nuggft._proofOf(tokenId);

        return parseProofLogic(proof);

        // TODO HAVE TO IMPLEMENT OVERRIDES AND EXTRA IDS
        // defaultIds = new uint256[](8);

        // for (uint256 i = 1; i < 6; i++) {
        //     defaultIds[i] = (proof >> (4 + (ITEMID_SIZE * 6) + ITEMID_SIZE * (i - 1)));
        // }
    }

    function parseProofLogic(uint256 _proof)
        internal
        pure
        returns (
            uint256 proof,
            uint256[] memory defaultIds,
            uint256[] memory extraIds,
            uint256[] memory overrides
        )
    {
        proof = _proof;
        defaultIds = new uint256[](_proof & ShiftLib.mask(4));

        for (uint256 i = 0; i < defaultIds.length; i++) {
            defaultIds[i] = (_proof >> (4 + i * 16)) & ShiftLib.mask(16);
        }
        extraIds = new uint256[](8);
        overrides = new uint256[](8);
    }

    function setProof(
        Token.Storage storage nuggft,
        uint256 tokenId,
        uint256 genesis
    ) internal {
        require(!hasProof(nuggft, tokenId), 'IL:M:0');

        (uint256 seed, uint256 epoch) = EpochLib.calculateSeed(genesis);

        require(seed != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        uint256 lendata = nuggft._vault.lengthData;

        seed = ProofType.initFromSeed(lendata, seed);

        nuggft._proofs[tokenId] = seed;

        (, uint256[] memory items, , ) = parseProofLogic(seed);

        emit SetProof(tokenId, items);
    }

    function push(
        Token.Storage storage nuggft,
        uint256 tokenId,
        uint256 itemId
    ) internal {
        uint256 working = proofOf(nuggft, tokenId);

        require(nuggft._ownedItems[itemId] > 0, '1155:SBTF:1');

        nuggft._ownedItems[itemId]--;

        (working, ) = working.pushFirstEmpty(uint16(itemId));

        nuggft._proofs[tokenId] = working;

        emit PushItem(tokenId, itemId);
    }

    function pop(
        Token.Storage storage nuggft,
        uint256 tokenId,
        uint256 itemId
    ) internal {
        uint256 working = proofOf(nuggft, tokenId);

        require(working != 0, '1155:STF:0');

        (working, , ) = working.popFirstMatch(uint16(itemId));

        nuggft._proofs[tokenId] = working;

        nuggft._ownedItems[itemId]++;

        emit PopItem(tokenId, itemId);
    }

    function open(Token.Storage storage nuggft, uint256 tokenId) internal {
        uint256 working = proofOf(nuggft, tokenId);

        working = working.size(working.size() + 1);

        nuggft._proofs[tokenId] = working;

        emit OpenSlot(tokenId);
    }
}
