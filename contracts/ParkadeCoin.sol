pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

// TODO: Implement SafeMath & ERC20 standards compliance
// TODO: Should anyone be able to deposit money in the contract? Or only the owner / creator (ie, ParkadeIO)

/**
    A dividend-paying token,
    based on https://programtheblockchain.com/posts/2018/02/07/writing-a-simple-dividend-token-contract/
    and https://programtheblockchain.com/posts/2018/02/13/writing-a-robust-dividend-token-contract/
*/
contract ParkadeCoin is StandardToken {

    string public name = "Parkade Coin";
    string public symbol = "PRKC";
    uint8 public decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 400000000 * (uint256(10) ** decimals);
    uint256 public scaling = uint256(10) ** 8;

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        // Initially assign all tokens to the contract's creator.
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
    }

    mapping(address => uint256) public scaledDividendbalances;

    uint256 public scaledDividendPerToken;

    mapping(address => uint256) public scaledDividendCreditedTo;

    function update(address account) internal {
        uint256 owed =
            scaledDividendPerToken - scaledDividendCreditedTo[account];
        scaledDividendbalances[account] += balances[account] * owed;
        scaledDividendCreditedTo[account] = scaledDividendPerToken;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);

        update(msg.sender);
        update(_to);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);


        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        update(_from);
        update(_to);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    uint256 public scaledRemainder = 0;

    function deposit() public payable {
        // scale the deposit and add the previous remainder
        uint256 available = (msg.value.mul(scaling)).add(scaledRemainder);

        scaledDividendPerToken += available / totalSupply_;

        // compute the new remainder
        scaledRemainder = available % totalSupply_;
    }

    function withdraw() public {
        update(msg.sender);
        uint256 amount = scaledDividendbalances[msg.sender] / scaling;
        scaledDividendbalances[msg.sender] %= scaling;  // retain the remainder
        msg.sender.transfer(amount);
    }
}