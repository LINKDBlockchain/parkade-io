/** 
 * @title Parkade.IO Parking Lot App Contract
 * @author LINKD Blockchain Solutions INC <info@linkd.ca>
 * @version 0.0.1 DRAFT - September 09, 2018 
 * 
 */
pragma solidity ^0.4.24;

contract ParkingLot {
    
    /** Public Variables */
    uint64 public lotNumber;
    uint256 public rate;
    
    /** Private Variables */
    mapping (address => uint256) private lotDatabase;
    
    /** Events */
    event checkedIn (
        uint256 _timestamp,
        address _addr
    );
    event checkedOut (
        uint256 _timestamp,
        address _addr
    );
    event rateUpdated (
        uint256 _timestamp,
        uint256 newRate
    );
    
    /**
     * @dev Constructs a new Parking Lot contract
     * @param lotNumber 64-bit numeric identifier of the lot
     * @param profitSharingWallet Address of the PRKC smart contract for dividend/profit profit sharing, where 50% of NET profits will be directed
     * @param parkadeIOWallet Address of Parkade.IO's wallet for future expansion, where 50% of NET profits will be directed
     * @param operationalWallet Address of Parkade.IO's wallet for operational expenses, where 10% of GROSS profits will be directed
     * @param initialRate Rate (in wei per minute) that parkers will be charged for parking at this lot
     */
    constructor (
    uint64 lotNumber, 
    address profitSharingWallet,
    address parkadeIOWallet,
    address operationalWallet,
    uint256 initialRate ) { }
    
    /** Public Functions */
    
    /**
     * @dev Check-In function
     * Checks a user into the parking lot, recording time of entrance and their Ethereum wallet address
     * Emits checkedIn event upon successful execution
     */
    function checkIn() public { }
    
    /**
     * @dev Check-Balance function
     * Calculates how much Ether a user must pay to exit the lot, so that they can leave within the next 10 minutes.
     * @returns uint256 value of how many Wei the user must pay to exit the lot
     */
    function checkBalance() public view returns (uint256) { }
    
    /**
     * @dev Check-Out function
     * Receives payment from the user, calculates whether payment is sufficient. If true, then removes the user's address from lotDatabase.
     * Refunds any excess payment back to the source Ethereum wallet
     * Automatically distributes resulting Eth to wallets:
     * * 10% of TOTAL Eth --> operationalWallet
     * * 50% of REMAINING Eth --> profitSharingWallet
     * * 50% of REMAINING Eth --> parkadeIOWallet
     * Emits checkedOut event upon successful execution
     */
    function checkOut() public payable { }
    
    /** Administrative Functions */
    
    /**
     * @dev Administrative interface to allow Parkade.IO to adjust parking fee rate. 
     * Can only be called by Controller contract.
     * @param newRate New rate to be applied (in Wei per Minute)
     */
    function adjustRate(uint256 newRate) public onlyController { }
    
    /**
     *@dev Administrative interface to allow Parkade.IO to decomission this lot smart contract. 
     * Can only be called by controller contract.
     */
    function destroyLot() public onlyController { }

    /**
     * @dev Administrative interface to allow Parkade.IO to check-out a user, in the event of other failure.
     * @param addr Address to check-out
     * Emits checkedOut event upon successful execution
     */
    function checkOutOverride(address addr) public onlyController { }
}
