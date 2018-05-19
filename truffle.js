// Allows us to use ES6 in our migrations and tests.
require('babel-register')({
  ignore: /node_modules\/(?!zeppelin-solidity)/
});
require('babel-register')
require('babel-polyfill')

module.exports = {
  networks: {
    development: {
        host: "localhost",
        port: 7545,
        network_id: "*" // Match any network id
    }
}
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
};
