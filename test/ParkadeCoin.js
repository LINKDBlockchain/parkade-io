const ParkadeCoin = artifacts.require('./ParkadeCoin.sol')

// Mocha testing truffle?
contract('ParkadeCoin', function( [owner] ) {
    let prkc

    beforeEach('setup contract for each test', async function () {
        let parkadeCoin = await ParkadeCoin.new()
        prkc = ParkadeCoin.at(parkadeCoin.address)
    })

    it('gives the owner his balance', async function () {
        // balanceOf is not working in this test, but seems to work ok in remix.
        let balance = await prkc.balanceOf(owner);
        // toNumber is required as balance returns a JS BigNumber
        // * 4 * 10 ^ 26 = 400 million * 10^18 (18 decimal places) 
        assert.equal(balance.toNumber(), 4 * Math.pow(10,26));
    })

    it('performs transfer correctly', async function () {
        let balance = await prkc.balanceOf(owner);

        // Specify half the tokens to be sent
        let newBalance = balance.toNumber() / 2;

        await prkc.transfer(web3.eth.accounts[1], newBalance);

        let transferredBalance = await prkc.balanceOf(web3.eth.accounts[1]);
        assert.equal(transferredBalance.toNumber(), newBalance);
    })

    it('doesnt transfer tokens when account balance is 0', async function () {
        

        assert.equal(thing1, thing2);
    })

    // Test for dividend deposit into the contract

    // Transfer tokens when you actually have none (transferAmount > your balance). Should fail

    // ! Test for dividend withdrawl !!
    // split up tokens 4 ways (25% each)
    // deposit 100 ETH into the contract
    // Have each account withdrawl sequentially
    // Check the balance / transaction amount

    // Do another dividend test, with uneven amounts (one person has 60%, another has 40%)

    // Dividend test for small amounts (<1%) 
    // What if you own 0.00001% of the tokens, do you get your dividends properly
    // ? What is the threshold when gas cost > dividend payout? *generally* ->  What is the transaction cost of withdraw()

    // Person A (50% of tokens) -> transfers 25% of them to Person B (BEFORE person A withdraws) -> then Person A and Person B both withdraw
    // What happens? What should happen

    // Person A (50% of tokens) -> Withdraws -> gives 25% of them to person B -> contract has a deposit -> Person A and B** get their dividends?

    // Allowance - works
})
