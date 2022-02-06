const ChatPuppyNFTCore = artifacts.require("ChatPuppyNFTCore");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        ChatPuppyNFTCore, 
        Env.get('NFT_NAME'),
        Env.get('NFT_SYMBOL'),
        Env.get('BASE_TOKEN_URI'),
        Env.get('INITIAL_CAP')
    );
};
