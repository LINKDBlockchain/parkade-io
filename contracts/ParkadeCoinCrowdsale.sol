pragma solidity 0.4.23;

import "./ParkadeCoin.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/WhitelistedCrowdsale.sol";

contract ParkadeCoinCrowdsale is TimedCrowdsale, RefundableCrowdsale, WhitelistedCrowdsale {
  // How many token units a buyer gets per wei
  uint256 public firstDiscountedRate;
  uint256 public secondDiscountedRate;

  uint256 public firstDiscountEnds;
  uint256 public secondDiscountEnds;

  function ParkadeCoinCrowdsale
  (
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _firstDiscountEnds,
    uint256 _secondDiscountEnds,
    uint256 _firstRate,
    uint256 _secondRate,
    uint256 _normalRate,
    uint256 _goal,
    address _wallet,
    StandardToken _token
  )

  public 
  Crowdsale(_firstRate, _wallet, _token) 
  TimedCrowdsale(_openingTime, _closingTime)
  RefundableCrowdsale(_goal)
  {
    firstDiscountedRate = _firstRate;
    secondDiscountedRate = _secondRate;
    firstDiscountEnds= _firstDiscountEnds;
    secondDiscountEnds = _secondDiscountEnds;
  }

  function hasOpened() public view returns (bool) {
    // TODO: Investigate this line. Without the comment below, says we shouldn't be using 
    //       block.timestamp at all but that's used a lot in the TimedCrowdsale library...
    // solium-disable-next-line security/no-block-members
    return block.timestamp > openingTime;
  }

  /**
  * @dev Public function that allows users to determine the current price (in wei) per token
  * @return Current price per token in wei
  */
  function currentRate() public view returns (uint256) {
    if (block.timestamp < firstDiscountEnds)
    {
      return firstDiscountedRate;
    }
    else if (block.timestamp > firstDiscountEnds && block.timestamp < secondDiscountEnds)
    {
      return secondDiscountedRate;
    }
    else 
    {
    return rate;
    }
  }

   /**
   * @dev Overriden token value function. Provides functionality for discounted rates in the tokensale
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {

    if (block.timestamp < firstDiscountEnds)
    {
      return _weiAmount.mul(firstDiscountedRate);
    }
    else if (block.timestamp > firstDiscountEnds && block.timestamp < secondDiscountEnds)
    {
      return _weiAmount.mul(secondDiscountedRate);
    }
    else 
    {
    return _weiAmount.mul(rate);
    }
  }
}