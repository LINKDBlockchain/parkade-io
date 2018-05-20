pragma solidity 0.4.24;

import "./ParkadeCoin.sol";
import "zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";


contract ParkadeCoinCrowdsale is TimedCrowdsale, MintedCrowdsale {

  function ParkadeCoinCrowdsale
  (
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _rate,
    address _wallet,
    MintableToken _token
  )

  public Crowdsale(_rate, _wallet, _token) TimedCrowdsale(_openingTime, _closingTime) {
  }

  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }
}