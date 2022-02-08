const TokensVesting = artifacts.require("TokensVesting");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        TokensVesting,
        Env.get('CPT_TOKEN_ADDRESS')
    );
};
