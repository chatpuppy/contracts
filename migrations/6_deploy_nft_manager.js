const ChatpuppyNFTManager = artifacts.require("ChatPuppyNFTManager");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        ChatpuppyNFTManager, 
        Env.get('MARKETPLACE_NFT_ADDRESS'),
        Env.get('ITEM_FACTORY'),
        Env.get('RANDOM_GENERATOR'),
        0, //Env.get('RANDOM_FEE')
        Env.get("PROJECT_ID"),
        Env.get('MYSTERY_BOX_PRICE'),
    );
};
