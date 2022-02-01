// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../interfaces/IItemFactory.sol";

contract ItemFactoryManager {
    IItemFactory public itemFactory;

    event ItemFactoryUpdated(address itemFactory_);

    constructor(address itemFactory_) {
        _updateItemFactory(itemFactory_);
    }

    function _updateItemFactory(address itemFactory_) internal {
        itemFactory = IItemFactory(itemFactory_);
        emit ItemFactoryUpdated(itemFactory_);
    }
}
