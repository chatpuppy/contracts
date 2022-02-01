const DragonaireNFTMarketplace = artifacts.require("DragonaireNFTMarketplace");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        DragonaireNFTMarketplace, 
        Env.get('MARKETPLACE_NFT_ADDRESS'),
        Env.get('MARKETPLACE_FEE_DECIMAL'),
        Env.get('MARKETPLACE_FEE_RATE'),
        Env.get('MARKETPLACE_FEE_RECIPIENT')
    );
};
