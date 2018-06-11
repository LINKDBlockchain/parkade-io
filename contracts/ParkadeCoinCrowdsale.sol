pragma solidity 0.4.24;

import "./ParkadeCoin.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/WhitelistedCrowdsale.sol";

contract ParkadeCoinCrowdsale is TimedCrowdsale, RefundableCrowdsale, WhitelistedCrowdsale {
  
  // Discounted Rates. This is the amount of tokens (of the smallest possible denomination ie- 0.0000...0001PRKC) 
  // that a user will receive per Wei contributed to the sale.
  uint256 public firstDiscountedRate = 1838;
  uint256 public secondDiscountedRate = 1634;
  uint256 public nonDiscountedRate = 1470;

  // Timestamp indicating when the crowdsale will open
  // Aug 1, 2018 12:00:00 AM GMT
  uint256 public openingTime = 1533081600;

  // Timestamps indicating when the first and second discount will end.
  // Aug 7, 2018 11:59:59PM GMT
  uint256 public firstDiscountEnds = 1533686399;
  // Aug 13, 2018 11:59:59PM GMT
  uint256 public secondDiscountEnds = 1534204799;

  // Timestamp indicating when the crowdsale will close
  // Aug 31, 2018 11:59:59PM GMT
  uint256 public closingTime = 1535759999;

  // Timestamp indicating when unsold tokens may be withdrawn by the Parkade.io wallet for future use
  // Sept 1, 2019 12:00:00AM GMT
  uint256 public unusedTokensWithdrawalTime = 1567296000;

  // A separate Ethereum address which only has the right to add addresses to the whitelist
  // It is not permitted to access any other functionality, or to claim funds
  // This is required for easier administration of the ParkadeCoin Crowdsale
  address public executor;

  // Whether refunds are allowed or not (regardless of if the tokensale's soft cap has been met)
  // This functionality allows Parkade.IO to refund all investors at the end of the tokensale, even if
  //  the soft cap is not met.
  bool refundsAllowed;

  function ParkadeCoinCrowdsale
  (
    uint256 _goal,
    uint256 _unusedTokensWithdrawalTime,
    address _owner,
    address _executor,
    StandardToken _token
  )
  public 
  Crowdsale(nonDiscountedRate, _owner, _token) 
  TimedCrowdsale(openingTime, closingTime)
  RefundableCrowdsale(_goal)
  {
    unusedTokensWithdrawalTime = _unusedTokensWithdrawalTime;
    executor = _executor;
    refundsAllowed = false;
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
    else if (block.timestamp >= firstDiscountEnds && block.timestamp < secondDiscountEnds)
    {
      return secondDiscountedRate;
    }
    else 
    {
      return rate;
    }
  }

// Note: Withdrawal goes to the "wallet" variable - specified during instantiation.
  function withdrawalUnsoldTokens(uint256 amount) external onlyOwner {
    require (block.timestamp > unusedTokensWithdrawalTime);
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
    return _weiAmount.mul(currentRate());
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