const ChatPuppyNFTManagerV2 = artifacts.require("ChatPuppyNFTManagerV2");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        ChatPuppyNFTManagerV2,
        Env.get('NFT_ADDRESS'),
        Env.get('ITEM_FACTORY'),
        Env.get('MYSTERY_BOX_PRICE'),
        Env.get('SUBSCRIPTION_ID'),
        Env.get('VRF_COORDINATOR_V2'),
        Env.get('VRF_HASH_KEY_V2'),
        Env.get('CALLBACK_GAS'),
        Env.get('REQUEST_CONFIRMATIONS')
    );
};
