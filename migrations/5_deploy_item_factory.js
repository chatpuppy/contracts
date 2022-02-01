const ItemFactory = artifacts.require("ItemFactory");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        ItemFactory,
        20
    );
};
