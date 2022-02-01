const PriceConsumerV3 = artifacts.require("PriceConsumerV3");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        PriceConsumerV3
    );
};
