const RandomTest = artifacts.require("RandomTest");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(
        RandomTest,
        Env.get('RANDOM_GENERATOR'),
        0
        // Env.get('RANDOM_FEE')
    );
};
