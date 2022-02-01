const ChainLinkRandomGenerator = artifacts.require("ChainLinkRandomGenerator");
const Env = require('../env');

module.exports = function (deployer) {
    // const params = {
    //     vrfCoordinator: Env.get('VRF_COORDINATOR'),
    //     link: Env.get('LINK_ADDRESS'),
    //     keyHash: Env.get('VRF_HASH_KEY'),
    //     fee: Env.get('CHAINLINK_FEE'),
    //     wrappedBnb: Env.get('WRAPPED_BNB'),
    //     pegLink: Env.get('PEG_LINK'),
    //     pegSwapRouter: Env.get('PEG_SWAP_ROUTER'),
    //     pancakeRouter: Env.get('PANCAKE_ROUTER'),
    // };
    // console.log(params);
    deployer.deploy(
        ChainLinkRandomGenerator,
        Env.get('VRF_COORDINATOR'),
        Env.get('LINK_ADDRESS'),
        Env.get('VRF_HASH_KEY'),
        Env.get('CHAINLINK_FEE'),
        Env.get('WRAPPED_BNB'),
        Env.get('PEG_LINK'),
        Env.get('PEG_SWAP_ROUTER'),
        Env.get('PANCAKE_ROUTER'),
    );
};
