pragma solidity 0.4.24;

import "./ParkadeCoin.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/WhitelistedCrowdsale.sol";

contract ParkadeCoinCrowdsale is TimedCrowdsale, RefundableCrowdsale, WhitelistedCrowdsale {

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
    // TODO: Investigate this line. Without the comment below, says we shouldn't be using 
    //       block.timestamp at all but that's used a lot in the TimedCrowdsale library...
    // solium-disable-next-line security/no-block-members
    return block.timestamp > openingTime;
  }
}