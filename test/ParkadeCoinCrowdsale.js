const ParkadeCoin = artifacts.require('./ParkadeCoin.sol')
const ParkadeCoinCrowdsale = artifacts.require('./ParkadeCoinCrowdsale.sol');

contract('ParkadeCoinCrowdsale', function( [owner] ) {
    let prkc;
    let prkcCrowdsale;

    beforeEach('setup contracts for each test', async function () {
        let parkadeCoin = await ParkadeCoin.new()
        //TODO: Fix this constructor?
        let parkadeCoinCrowdsale = await ParkadeCoinCrowdsale.new(100,200,300,400,owner,parkadeCoin.address);
        prkc = ParkadeCoin.at(parkadeCoin.address)
        prkcCrowdsale = ParkadeCoinCrowdsale.at(parkadeCoinCrowdsale.address)
    });

    // TODO: Complete this ownership test
    if('transfers token contract ownership successfully', async function() {
        let balanceOwner = await prkc.balanceOf(owner);

        prkc.transfer(prkcCrowdsale.address, balanceOwner.toNumber()/2);

        let balanceCrowdsale = await prkc.balanceOf(prkcCrowdsale.address)
        assert(balanceCrowdsale, balanceOwner.toNumber()/2);
    });


});