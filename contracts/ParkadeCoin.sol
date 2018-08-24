pragma solidity 0.4.24;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


/**
    @title A dividend-paying ERC20 token,
    @dev Based on https://programtheblockchain.com/posts/2018/02/07/writing-a-simple-dividend-token-contract/
          and https://programtheblockchain.com/posts/2018/02/13/writing-a-robust-dividend-token-contract/
*/
contract ParkadeCoin is StandardToken, Ownable {
  using SafeMath for uint256;
  string public name = "Parkade Coin";
  string public symbol = "PRKC";
  uint8 public decimals = 18;


  /**
    There are a total of 400,000,000 tokens * 10^18 = 4 * 10^26 token units total
    A scaling value of 1e10 means that a deposit of 0.04Eth will increase scaledDividendPerToken by 1.
    A scaling value of 1e10 means that investors must wait until their scaledDividendBalances 
      is at least 1e10 before any withdrawals will credit their account.
  */
  uint256 public scaling = uint256(10) ** 10;

  // Remainder value (in Wei) resulting from deposits
  uint256 public scaledRemainder = 0;

  // Amount of wei credited to an account, but not yet withdrawn
  mapping(address => uint256) public scaledDividendBalances;
  // Cumulative amount of Wei credited to an account, since the contract's deployment
  mapping(address => uint256) public scaledDividendCreditedTo;
  // Cumulative amount of Wei that each token has been entitled to. Independent of withdrawals
  uint256 public scaledDividendPerToken = 0;

  /**
   * @dev Throws if transaction size is greater than the provided amount
   * This is used to mitigate the Ethereum short address attack as described in https://tinyurl.com/y8jjvh8d
   */
  modifier onlyPayloadSize(uint size) { 
    assert(msg.data.length >= size + 4);
    _;    
  }

  constructor() public {
    // Total INITAL SUPPLY of 400 million tokens 
    totalSupply_ = uint256(400000000) * (uint256(10) ** decimals);
    // Initially assign all tokens to the contract's creator.
    balances[msg.sender] = totalSupply_;
    emit Transfer(address(0), msg.sender, totalSupply_);
  }

  /**
  * @dev Update the dividend balances associated with an account
  * @param account The account address to update
  */
  function update(address account) 
  internal 
  {
    // Calculate the amount "owed" to the account, in units of (wei / token) S
    // Subtract Wei already credited to the account (per token) from the total Wei per token
    uint256 owed = scaledDividendPerToken.sub(scaledDividendCreditedTo[account]);

    // Update the dividends owed to the account (in Wei)
    // # Tokens * (# Wei / token) = # Wei
    scaledDividendBalances[account] = scaledDividendBalances[account].add(balances[account].mul(owed));
    // Update the total (wei / token) amount credited to the account
    scaledDividendCreditedTo[account] = scaledDividendPerToken;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Deposit(uint256 value);
  event Withdraw(uint256 paidOut, address indexed to);

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) 
  public 
  onlyPayloadSize(2*32) 
  returns (bool success) 
  {
    require(balances[msg.sender] >= _value);

    // Added to transfer - update the dividend balances for both sender and receiver before transfer of tokens
    update(msg.sender);
    update(_to);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value)
  public
  onlyPayloadSize(3*32)
  returns (bool success)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    // Added to transferFrom - update the dividend balances for both sender and receiver before transfer of tokens
    update(_from);
    update(_to);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
  * @dev deposit Ether into the contract for dividend splitting
  */
  function deposit() 
  public 
  payable 
  onlyOwner 
  {
    // Scale the deposit and add the previous remainder
    uint256 available = (msg.value.mul(scaling)).add(scaledRemainder);

    // Compute amount of Wei per token
    scaledDividendPerToken = scaledDividendPerToken.add(available.div(totalSupply_));

    // Compute the new remainder
    scaledRemainder = available % totalSupply_;

    emit Deposit(msg.value);
  }

  /**
  * @dev withdraw dividends owed to an address
  */
  function withdraw() 
  public 
  {
    // Update the dividend amount associated with the account
    update(msg.sender);

    // Compute amount owed to the investor
    uint256 amount = scaledDividendBalances[msg.sender].div(scaling);
    // Put back any remainder
    scaledDividendBalances[msg.sender] %= scaling;

    // Send investor the Wei dividends
    msg.sender.transfer(amount);

    emit Withdraw(amount, msg.sender);
  }
}