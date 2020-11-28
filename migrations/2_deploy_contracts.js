//NOTE: This file is VERY important. Make sure you deploy to check with tests!
var Marketplace = artifacts.require('./Marketplace.sol');

module.exports = function(deployer) {
  deployer.deploy(Marketplace);
};
