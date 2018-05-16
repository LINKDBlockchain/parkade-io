const ParkadeCoin = artifacts.require('./ParkadeCoin.sol')

contract('ParkadeCoin', function( [owner] ) {
    let parkadeCoin

    beforeEach('setup contract for each test', async function () {
        parkadeCoin = await ParkadeCoin.new()
    })

    it('gives the owner his balance', async function () {
        // balanceOf is not working in this test, but seems to work ok in remix.
        let balance = await parkadeCoin.balanceOf(owner);
        console.log(balance);
        assert.equal(balance, 10000000000000000);
    })
})