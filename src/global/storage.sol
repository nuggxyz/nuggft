import {Vault} from '../vault/storage.sol';
import {Stake} from '../stake/storage.sol';
import {Swap} from '../swap/storage.sol';
import {Proof} from '../proof/storage.sol';

library Global {
    struct Storage {
        // Token symbol
        Token.Storage token;
        // Token symbol
        Stake.Storage stake;
        // Token symbol
        Vault.Storage vault;
        // Token symbol
        Proof.Storage proof;
        //
        Loan.Storage loan;
        //
        Swap.Storage swap;
        mapping(uint256 => uint256) _ownedItems;
    }

    function ptr() internal returns (Storage storage s) {
        assembly {
            s.slot := 1
        }
    }
}
