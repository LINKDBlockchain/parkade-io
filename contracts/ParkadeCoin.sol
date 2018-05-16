pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC20/BasicToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

// TODO: Implement SafeMath & ERC20 standards compliance
// TODO: Should anyone be able to deposit money in the contract? Or only the owner / creator (ie, ParkadeIO)
pragma solidity ^0.4.21;

/**
    A dividend-paying token,
    based on https://programtheblockchain.com/posts/2018/02/07/writing-a-simple-dividend-token-contract/
    and https://programtheblockchain.com/posts/2018/02/13/writing-a-robust-dividend-token-contract/
*/
contract ParkadeCoin is BasicToken {

    string public name = "Parkade Coin";
    string public symbol = "PRKC";
    uint8 public decimals = 18;

    uint256 totalSupply_ = 1000000 * (uint256(10) ** decimals);

    mapping(address => uint256) public balances;

    function ParkadeCoin() public {
        // Initially assign all tokens to the contract's creator.
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    uint256 public scaling = uint256(10) ** 8;

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

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balances[msg.sender] >= value);

        update(msg.sender);
        update(to);

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
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