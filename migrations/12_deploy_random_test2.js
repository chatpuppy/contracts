const RandomTestV2 = artifacts.require("RandomTestV2");
const Env = require('../env');

module.exports = function (deployer) {
    // console.log(
    //     Env.get('SUBSCRIPTION_ID'),
    //     Env.get('VRF_COORDINATOR_V2'),
    //     Env.get('VRF_HASH_KEY_V2'),
    //     Env.get('LINK_ADDRESS_V2'),
    //     Env.get('CALLBACK_GAS')
    // )
    deployer.deploy(
        RandomTestV2,
        Env.get('SUBSCRIPTION_ID'),
        Env.get('VRF_COORDINATOR_V2'),
        Env.get('VRF_HASH_KEY_V2'),
        Env.get('LINK_ADDRESS_V2'),
        Env.get('CALLBACK_GAS')
    );
};
