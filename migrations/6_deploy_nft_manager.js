const ChatpuppyNFTManager = artifacts.require("ChatPuppyNFTManager");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        ChatpuppyNFTManager, 
        Env.get('NFT_NAME'),
        Env.get('NFT_SYMBOL'),
        Env.get('BASE_TOKEN_URI'),
        Env.get('INITIAL_CAP'),
        Env.get('ITEM_FACTORY'),
        Env.get('RANDOM_GENERATOR'),
        0, //Env.get('RANDOM_FEE')
        Env.get("PROJECT_ID"),
    );
};
