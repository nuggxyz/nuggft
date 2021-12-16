import {Vault} from './storage.sol';

library VaultView {
    function hasResolver(uint256 tokenId) internal view returns (bool) {
        return Vault.ptr().resolvers[tokenId] != address(0);
    }
}
