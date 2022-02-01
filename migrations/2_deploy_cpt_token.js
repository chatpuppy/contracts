const CPTToken = artifacts.require("CPTToken");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(CPTToken);
};
