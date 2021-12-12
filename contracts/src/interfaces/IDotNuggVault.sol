// SPDX-License-Identifier: MIT

interface IdotnuggVault {
    function select(uint256 feature, uint256 id) external view returns (uint256[] memory res);

    function select(uint256[] memory feature, uint256[] memory id) external view returns (uint256[][] memory res);
}
