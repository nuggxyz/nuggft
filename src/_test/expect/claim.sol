//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {RiggedNuggft} from '../NuggftV1.test.sol';

abstract contract expectClaim {
    function nuggft() internal virtual returns (RiggedNuggft);

    function start(
        uint160[] memory tokenIds,
        uint160[] memory offerers,
        address sender
    ) internal {
        address[] memory a;
        assembly {
            a := offerers
        }
        start(tokenIds, a, sender);
    }

    struct Snapshot {
        uint160 id;
        bool isItem;
        uint256 offer;
        uint256 agency;
        address winner;
    }

    struct Run {
        Snapshot[] snapshots;
        address sender;
    }

    function start(
        uint160[] memory tokenIds,
        address[] memory offerers,
        address sender
    ) internal returns (bytes memory) {
        require(tokenIds.length == offerers.length, 'EXPECT-CLAIM:START:ArrayLengthNotSame');

        Run memory run;

        run.sender = sender;

        run.snapshots = new Snapshot[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            Snapshot memory snapshot;

            snapshot.id = tokenIds[i];
            snapshot.isItem = snapshot.id > 0xffffff;

            if (snapshot.isItem) {
                // QUESTION: what should things look like before an item claim
                snapshot.agency = nuggft().external__itemAgency(snapshot.id);
                snapshot.offer = nuggft().external__offerItemAgency(snapshot.id);
            } else {
                // QUESTION: what should things look like before an nugg claim
                snapshot.agency = nuggft().external__agency(snapshot.id);
                snapshot.offer = nuggft().external__offerAgency(snapshot.id);
            }

            snapshot.winner = (96 << snapshot.agency) >> 96 == (96 << snapshot.offer) >> 96;

            run.snapshots[i] = snapshot;
        }

        return abi.encode(run);
    }

    function stop(bytes memory input) internal {
        Run memory run = abi.decode(input, (Run));

        for (uint256 i = 0; i < run.snapshots.length; i++) {
            Snapshot memory shared = run.snapshots[i];
            Snapshot memory before = shared;
            Snapshot memory end;

            if (shared.isItem) {
                // QUESTION: what should things look like before an item claim
                shared.agency = nuggft().external__itemAgency(shared.id);
                shared.offer = nuggft().external__offerItemAgency(shared.id);
            } else {
                // QUESTION: what should things look like before an nugg claim
                shared.agency = nuggft().external__agency(shared.id);
                shared.offer = nuggft().external__offerAgency(shared.id);
            }

            if (before.isItem) {
                if (shared.isWinner) {
                    // QUESTION: what should happen on a winning item claim
                    // -- the item should be inside the winning nugg's proof
                    // -- the
                } else {
                    // QUESTION: what should happen on a losing item claim
                    // -- make sure that the owner is also the sender... otherwise should have failed before this
                    // -- add the value earned to the total amount the user should have earned
                    // -- remove the amount from the total amount nuggft's balance should have changed by
                    //
                }
            } else {
                if (shared.isWinner) {
                    // QUESTION: what should happen on a winning nugg claim
                    // make sure the nugg is owned by the
                } else {
                    // QUESTION: what should happen on a losing item claim
                    // -- add the value earned to the total amount the user should have earned
                    // -- remove the amount from the total amount nuggft's balance should have changed by
                }
            }
        }
    }
}
