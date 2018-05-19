pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC20/BasicToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

// TODO: Implement SafeMath & ERC20 standards compliance
// TODO: Should anyone be able to deposit money in the contract? Or only the owner / creator (ie, ParkadeIO)

/**
    A dividend-paying token,
    based on https://programtheblockchain.com/posts/2018/02/07/writing-a-simple-dividend-token-contract/
    and https://programtheblockchain.com/posts/2018/02/13/writing-a-robust-dividend-token-contract/
*/
contract ParkadeCoin is BasicToken {

    string public name = "Parkade Coin";
    string public symbol = "PRKC";
    uint8 public decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 400000000 * (uint256(10) ** decimals);
    uint256 public scaling = uint256(10) ** 8;

    // mapping(address => uint256) public balances;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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

    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool success)
    {
        require(value <= balances[from]);
        require(value <= allowance[from][msg.sender]);

        update(from);
        update(to);

        balances[from] -= value;
        balances[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    uint256 public scaledRemainder = 0;

    function deposit() public payable {
        // scale the deposit and add the previous remainder
        uint256 available = (msg.value * scaling) + scaledRemainder;

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

    function approve(address spender, uint256 value)
        public
        returns (bool success)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

}