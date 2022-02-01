const DragonaireNFTCore = artifacts.require("DragonaireNFTCore");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        DragonaireNFTCore, 
        Env.get('NFT_NAME'),
        Env.get('NFT_SYMBOL'),
        Env.get('BASE_TOKEN_URI'),
        Env.get('INITIAL_CAP')
    );
};
