let keys = require('../client/src/data/keys.json');
var Rating = artifacts.require("./Rating.sol");

module.exports = function(deployer) {
  deployer.deploy(Rating, keys.address);
};
