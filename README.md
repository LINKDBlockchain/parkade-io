# PARKADE.IO

This is the smart contract repository for the PARKADE.IO token, and tokensale. Relevant source code files are located in the contracts/ folder.

## Token Contract

### About
The token contract is a standard ERC20 token with added dividend-paying functionality. It is based on OpenZeppelin Solidity Templates, and Todd Proebsting's Dividend Token Contract code, linked [here](https://programtheblockchain.com/posts/2018/02/07/writing-a-simple-dividend-token-contract/), and [here](https://programtheblockchain.com/posts/2018/02/13/writing-a-robust-dividend-token-contract/)

### Stats
Name: Parkade Coin
Symbol: PRKC
Total Tokens: 400 million
Decimal Places: 18

### Functionality

#### Depositing Dividends
The owner of the contract can deposit dividends for distribution to investors by calling the payable `deposit` function.

### Withdrawing Dividends
Investors must withdraw dividends assigned to them by calling the `withdraw` function. Dividends are not automatically send to investor's accounts. The amount of dividends owing to an account is updated at the time of deposit, and thus they do not move as the tokens are transferred. 

For instance, if a user was owed dividends and then transferred his tokens to another user, he would still be able to collect his dividends owing.

**NOTE** _Any tokens held in an exchange account will not entitle users to their dividends, as the tokens are technically owned by the exchange's wallet. Thus, please ensure you are holding your tokens in your personal wallet when dividend payout takes place otherwise you will not be able to withdraw it._

## Tokensale Contract

### About
A standard, timed, refundable, whitelist-compatible crowdsale contract designed for Parkade.IO tokensale.

### Stats
**Please see [parkade.io](http://www.parkade.io) for more info**
Opening Time: August 1st, 2018 12:00AM GMT
Closing Time: August 31st, 2018 11:59PM GMT
Soft Cap: 680ETH
Hard Cap: 138,720 ETH

Table 1: Token price per timeframe
| Timeframe     | Token Price (Eth) |
| ------------- |:-------------:|
| Aug 1 - Aug 7   | 0.000544    |
| Aug 7 - Aug 14  | 0.000612    |
| Aug 14 - Aug 31 | 0.000680    |

Token Disbursement: Immediately after purchase
Refund Policy: After August 31st if soft cap is unmet, or at the discretion of parkade.io team

### Functionality
Functionality is typical of most crowdsales. Investors may only contribute once they have been added to the whitelist following KYC/AML validation. Please see [parkade.io](http://www.parkade.io) for more details.

# Dev Stuff
## Flattening tokensale files for export
1. Install:
``` npm install -g truffle-flattener ```

2. Specify "parent" file, and direct output
``` truffle-flattener contracts\ParkadeCoinCrowdsale.sol > output.txt ```
