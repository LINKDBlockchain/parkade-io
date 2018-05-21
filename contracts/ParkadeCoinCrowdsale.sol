pragma solidity 0.4.24;

import "./ParkadeCoin.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";

contract ParkadeCoinCrowdsale is TimedCrowdsale, RefundableCrowdsale {

  function ParkadeCoinCrowdsale
  (
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _rate,
    uint256 _goal,
    address _wallet,
    StandardToken _token
  )

  public 
  Crowdsale(_rate, _wallet, _token) 
  TimedCrowdsale(_openingTime, _closingTime)
  RefundableCrowdsale(_goal)
  {}

  function hasOpened() public view returns (bool) {
    return block.timestamp > openingTime;
  }
}