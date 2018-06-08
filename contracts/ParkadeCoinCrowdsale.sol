pragma solidity 0.4.24;

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

  uint256 public unusedTokensWithdrawlTime;

  address public executor;

  bool refundsAllowed;

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
    uint256 _unusedTokensWithdrawlTime,
    address _owner,
    address _executor,
    StandardToken _token
  )

  public 
  Crowdsale(_normalRate, _owner, _token) 
  TimedCrowdsale(_openingTime, _closingTime)
  RefundableCrowdsale(_goal)
  {
    firstDiscountedRate = _firstRate;
    secondDiscountedRate = _secondRate;
    firstDiscountEnds= _firstDiscountEnds;
    secondDiscountEnds = _secondDiscountEnds;
    unusedTokensWithdrawlTime = _unusedTokensWithdrawlTime;
    executor = _executor;
    refundsAllowed = true;
  }

  /**
   * @dev Throws if called by any account other than the owner OR the executor.
   */
  modifier onlyOwnerOrExecutor() {
    require(msg.sender == owner || msg.sender == executor);
    _;
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

// ! Functionality has been validated
// Note: Withdrawl goes to the "wallet" variable - specified during instantiation.
  function withdrawUnsoldTokens(uint256 amount) external onlyOwner {
    require (block.timestamp > unusedTokensWithdrawlTime);
    _processPurchase(wallet, amount);
  }

// ! Functionality has been validated
// Note: Withdrawl goes to the "wallet" variable - specified during instantiation.
  function changeExecutor(address _newExec) external onlyOwnerOrExecutor {
    require(_newExec != address(0));
    executor = _newExec;
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

   /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(address _beneficiary) external onlyOwnerOrExecutor {
    whitelist[_beneficiary] = true;
  }

  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _beneficiaries) external onlyOwnerOrExecutor {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

  /**
   * @dev Removes single address from whitelist.
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) external onlyOwnerOrExecutor {
    whitelist[_beneficiary] = false;
  }


    /**
   * @dev Validation of an incoming purchase. Overridden to ensure that the tokensale contains enough tokens to sell.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    // TODO: Validate this functionality
    require(token.balanceOf(this) > _getTokenAmount(_weiAmount));
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

    /**
   * @dev Investors can claim refunds here if crowdsale is unsuccessful (softcap not reached or as specified by owner)
   */
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached() || refundsAllowed == true);

    vault.refund(msg.sender);
  }

/**
* @dev Allow the tokensale owner to specify that refunds are allowed regardless of soft cap goal
*/
  function allowRefunds() external onlyOwner {
      require(hasClosed());
      refundsAllowed = true;
  }

}