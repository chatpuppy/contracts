const ChatpuppyNFTManager = artifacts.require("ChatPuppyNFTManager");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        ChatpuppyNFTManager, 
        Env.get('NFT_ADDRESS'),
        Env.get('ITEM_FACTORY'),
        Env.get('RANDOM_GENERATOR'),
        Env.get('RANDOM_FEE'),
        Env.get('MYSTERY_BOX_PRICE'),
    );
};
