const ChatPuppyNFTMarketplace = artifacts.require("ChatPuppyNFTMarketplace");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        ChatPuppyNFTMarketplace, 
        Env.get('NFT_ADDRESS'),
        Env.get('CPT_TOKEN_ADDRESS'),
        Env.get('MARKETPLACE_FEE_DECIMAL'),
        Env.get('MARKETPLACE_FEE_RATE'),
        Env.get('MARKETPLACE_FEE_RECIPIENT')
    );
};
