pragma solidity ^0.4.24;

//------------------------------------------------------------------------------------//
// @author:  Ebude 
// Date: 01/10/2018
// For Sales of Land with use of Smart Contracts.
// using a land coin as representation of actual cash.
//------------------------------------------------------------------------------------//

contract LandSale {
    
    struct Land {
        address landlord;  // address of the owner of this land
        uint longitude;
        uint latitude;   // the location on the map
        uint area;      // size of the land
        uint landtitle; //registration number of the land by state authority
        uint price; //lowest price it can be sold
        mapping (uint => Bidder) bidders;
    }
    
    struct Bidder {
        address addr;
        uint amount; // amount in the account of the seller
       
    }
    
    address public newowner;
    
    uint numlands= 0;
    uint numbidders= 0;
    mapping (uint=>Land) SLand;
   
    
    function newland(address landlord,uint longitude,uint latitude,uint area,uint price) public returns (uint landID){
        landID=numlands++; 
        SLand[landID]=Land (landlord,longitude,latitude,area,landID,price);
        
    }
    
    uint[] data;
    function landbidding(uint landID) public payable returns (uint){
        Land storage c=SLand[landID];
        c.bidders[numbidders++]=Bidder (msg.sender, msg.value);
        data.push(msg.value);
        for (uint i = 1;i < data.length;i++){
            uint temp = data[i];
            uint j;
            for (j = i -1; j >= 0 && temp < data[j]; j--){
                data[j+1] = data[j];
            }
            data[j + 1] = temp;
       }
       // sorted in ascending order
       return data[data.length];
    }
    
   
    uint bid;
    function Newowner(uint landID) public returns (address ){
        bid=landbidding(landID);
        newowner=msg.sender;
        return newowner;
    }
    
    event Sold(address owner, address newowner, uint landID, uint price);
    
    
    function sale(uint landID) public returns(bytes32 message){
       LandCoin Coin=new LandCoin(); // calling a contract in another contract.
       bid=landbidding(landID);
       if (bid>=SLand[landID].price){
           emit Sold(SLand[landID].landlord,Newowner(landID),landID,bid );
           Coin.Send(SLand[landID].landlord,bid);
           SLand[landID].landlord= Newowner(landID);
           
           message= 'Land has been sold';  
         
       }
       else {
           message= 'Bidding still open';
       }
       
    }
    
    
}


// Buid a coin that will be used to  do transactions 
// 1 LandCoin is equivalent to 100.00 USD.

contract LandCoin{
    
    address public newowner;
    mapping (address=>uint) public balances;
    
    // create an event of exchange of money
    
    event Sent(address fro, address to, uint amount );
    
    // code runs when the contract is created
    constructor() public{
        newowner=msg.sender;
    }
    
    function Receive(address receiver, uint amount) public{
        require(msg.sender==newowner);
        balances[receiver]+= amount;
    }
    
    function Send(address receiver, uint amount) public{
        require(amount <= balances[msg.sender],"Insufficient balance.");
        balances[msg.sender]-=amount;
        balances[receiver]+=amount;
        emit Sent(msg.sender, receiver, amount);
    }
    
}