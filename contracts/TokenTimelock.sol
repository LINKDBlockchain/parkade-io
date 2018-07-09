pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
  using SafeMath for uint256;

  // ERC20 basic token contract being held
  StandardToken public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public cliffPeriod;

  // 30 days
  uint256 public vestingPeriod = 2678400;

  uint256 public chunksAlreadyVested;

  uint256 totalAmount;

  function TokenTimelock(StandardToken _token, address _beneficiary, uint256 _cliffPeriod) public {
    // solium-disable-next-line security/no-block-members
    require(_cliffPeriod > block.timestamp);

    chunksAlreadyVested = 0;

    token = _token;
    beneficiary = _beneficiary;
    cliffPeriod = _cliffPeriod;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= cliffPeriod);

    // How many full months have gone by since beginning 
    uint256 chunksNeeded = (block.timestamp.sub(cliffPeriod)).div(vestingPeriod) + 1;

    // Prevent vesting more than 100% of tokens
    if (chunksNeeded > 10)
    {
      chunksNeeded = 10;
    }

    // Figure out how many more months since last time vesting occurred
    uint256 chunksToVest = chunksNeeded.sub(chunksAlreadyVested);

    require (chunksToVest > 0);

    // If this is the first time vesting has happened,
    if (chunksAlreadyVested == 0) 
    {
      // Set the total amount, as no new tokens will enter this contract
      totalAmount = token.balanceOf(this);
    }

    // Divide total balance by 10, multiply by number of chunks to vest
    uint256 amount = (totalAmount.div(10)).mul(chunksToVest);
    require(amount > 0);

    chunksAlreadyVested = chunksNeeded;

    token.transfer(beneficiary, amount);
  }
}
