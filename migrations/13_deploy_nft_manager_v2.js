const ChatPuppyNFTManagerV2 = artifacts.require("ChatPuppyNFTManagerV2");
const Env = require('../env');

module.exports = function (deployer) {
    // console.log(
    //     Env.get('NFT_NAME'),
    //     Env.get('NFT_SYMBOL'),
    //     Env.get('BASE_TOKEN_URI'),
    //     Env.get('INITIAL_CAP'),
    //     Env.get('ITEM_FACTORY'),
    //     // Env.get("PROJECT_ID"),
    //     Env.get('MYSTERY_BOX_PRICE'),
    //     Env.get('SUBSCRIPTION_ID'),
    //     Env.get('VRF_COORDINATOR_V2'),
    //     Env.get('VRF_HASH_KEY_V2'),
    //     Env.get('LINK_ADDRESS_V2'),
    //     Env.get('CALLBACK_GAS')
    // )

    deployer.deploy(
        ChatPuppyNFTManagerV2,
        Env.get('NFT_NAME'),
        Env.get('NFT_SYMBOL'),
        Env.get('BASE_TOKEN_URI'),
        Env.get('INITIAL_CAP'),
        Env.get('ITEM_FACTORY'),
        // Env.get("PROJECT_ID"),
        Env.get('MYSTERY_BOX_PRICE'),
        Env.get('SUBSCRIPTION_ID'),
        Env.get('VRF_COORDINATOR_V2'),
        Env.get('VRF_HASH_KEY_V2'),
        Env.get('LINK_ADDRESS_V2'),
        Env.get('CALLBACK_GAS')
    );
};
