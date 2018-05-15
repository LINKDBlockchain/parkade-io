# PARKADE.IO

Initial truffle setup copied from https://blog.zeppelin.solutions/how-to-create-token-and-initial-coin-offering-contracts-using-truffle-openzeppelin-1b7a5dae99b6

## To setup Dev Environment:
1. If you don't already have truffle, installed, run
``` npm install -g truffle ```

2. From this directory, execute this to build the code:
``` truffle compile ```

3. Launch Ganache or Ganache-cli (Win 7)
Note: If you're using Ganache-cli, you may have to modify truffle.js port to port: 8545

4. Run this to deploy the code!
``` truffle migrate ```

5. Interact with the contracts by firing up a truffle console:
``` truffle console ```