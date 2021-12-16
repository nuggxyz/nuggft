import {Global} from '../global/storage.sol';

import {SwapStorage} from './storage.sol';

library SwapView {
    function getOfferByAccount(
        uint256 tokenid,
        uint256 index,
        address account
    ) external view override returns (uint256 amount) {
        (, uint256 offerData) = SwapStorage.loadStorage(account, index);
        require(offerData != 0, 'NS:GS:0');
        amount = offerData.eth();
    }
}
