const ChainLinkRandomGenerator = artifacts.require("ChainLinkRandomGenerator");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        ChainLinkRandomGenerator,
        Env.get('VRF_COORDINATOR'),
        Env.get('LINK_ADDRESS'),
        Env.get('VRF_HASH_KEY'),
        Env.get('CHAINLINK_FEE'),
    );
};
