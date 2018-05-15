pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

contract ParkadeCoin is MintableToken
{
    string public name = "Parkade Coin";
    string public symbol = "PRKC";
    uint8 public decimals = 18;
}
