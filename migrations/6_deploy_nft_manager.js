const DragonaireNFTManager = artifacts.require("DragonaireNFTManager");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        DragonaireNFTManager, 
        Env.get('NFT_NAME'),
        Env.get('NFT_SYMBOL'),
        Env.get('BASE_TOKEN_URI'),
        Env.get('INITIAL_CAP'),
        Env.get('ITEM_FACTORY'),
        Env.get('RANDOM_GENERATOR'),
        0, //Env.get('RANDOM_FEE')
    );
};
