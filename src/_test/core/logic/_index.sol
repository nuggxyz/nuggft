import './logic__CastLib.t.sol';
import './logic__NuggftV1Epoch.t.sol';
import './logic__NuggftV1Loan.t.sol';
import './logic__NuggftV1Proof.t.sol';
import './logic__NuggftV1Stake.t.sol';
import './logic__ShiftLib.t.sol';
import './logic__TransferLib.t.sol';

contract Logic is logic__ShiftLib, logic__TransferLib, logic__NuggftV1Stake, logic__NuggftV1Loan, logic__NuggftV1Proof, logic__NuggftV1Epoch, logic__CastLib {}
