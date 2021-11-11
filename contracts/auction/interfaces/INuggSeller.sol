pragma solidity 0.8.4;

import './IAuctionable.sol';
import '../../interfaces/ISeedable.sol';
import '../../interfaces/IEpochable.sol';

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface INuggSeller is IAuctionable {
    event SaleStart(uint256 saleId, uint256 tokenId, uint256 floor, uint256 length);

    event SaleStop(uint256 saleId);

    struct Sale {
        uint256 startblock;
        uint256 length;
        uint256 floor;
        address seller;
        uint256 tokenId;
        bool claimed;
        bool sold;
    }

    function lastSaleByToken(uint256 tokenId) external returns (uint256 res);
}
