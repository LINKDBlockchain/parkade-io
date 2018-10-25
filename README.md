# PARKADE.IO

This is the smart contract repository for the PARKADE.IO token. Relevant source code files are located in the contracts/ folder.

**The official (deployed) Parkade.io Token Smart Contract is located HERE**
[0x3b5D7063206eb65Ea0880Ee93bEaBc65e73C313E](https://etherscan.io/address/0x3b5D7063206eb65Ea0880Ee93bEaBc65e73C313E)

## Token Contract

### About
The token contract is a standard ERC20 token with added dividend-paying functionality. It is based on OpenZeppelin Solidity Templates, and Todd Proebsting's Dividend Token Contract code, linked [here](https://programtheblockchain.com/posts/2018/02/07/writing-a-simple-dividend-token-contract/), and [here](https://programtheblockchain.com/posts/2018/02/13/writing-a-robust-dividend-token-contract/)

### Stats
Type: ERC20 Token with added features\
Name: Parkade Coin\
Symbol: PRKC\
Total Tokens: 400 million\
Decimal Places: 18

### Functionality

### Depositing Dividends
The owner of the contract can deposit dividends for distribution to investors by calling the payable `deposit` function.

### Withdrawing Dividends
Investors must withdraw dividends assigned to them by calling the `withdraw` function. Dividends are not automatically sent to investor's accounts. The amount of dividends owing to an account is updated at the time of deposit, and thus they do not move as the tokens are transferred. 

For instance, if a user was owed dividends and then transferred his tokens to another user, he would still be able to collect his dividends owing.

**NOTE** _Tokens must be held in user's personal wallets to be entitled to their dividends. Thus, please ensure you are not holding your tokens in an exchange account when dividend payout takes place otherwise you will not be able to withdraw the dividend._

**Please see [parkade.io](http://www.parkade.io) for more info**