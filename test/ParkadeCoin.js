const ParkadeCoin = artifacts.require('./ParkadeCoin.sol')

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
})
