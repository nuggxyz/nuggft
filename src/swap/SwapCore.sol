// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggFT} from '../interfaces/INuggFT.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Swap} from './SwapStorage.sol';
import {SwapPure} from '../swap/SwapPure.sol';

import {StakeCore} from '../stake/StakeCore.sol';

import {ProofCore} from '../proof/ProofCore.sol';

import {TokenCore} from '../token/TokenCore.sol';
import {TokenView} from '../token/TokenView.sol';

library SwapCore {
    using SafeCastLib for uint256;
    using SwapPure for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            COMMON FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/
}
