// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable public auctioneer;
    uint public endTime;
    // Bidder identify
    address public highestBidder;
    uint public highestBid;
    bool ended;
    event highestBidIncreased(address _highestBidder, uint amount);
    event winnerAuction(address _winner, uint _amount);

    mapping (address => uint) public pendingReturns;

    constructor(address payable _beneficiary,uint _biddingTime) {
        auctioneer = _beneficiary;
        endTime = _biddingTime + block.timestamp;
    }

    function bid() public payable{
        if (block.timestamp > endTime) {revert("The auction is ended");}
        if (msg.value < highestBid){ revert("You're bid is less than highest bid you bitch!");}
        if (highestBid != 0){ pendingReturns[highestBidder] += highestBid;}
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit highestBidIncreased(msg.sender, msg.value);

    }   


    function withdraw() public payable returns(bool){
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
        }

        if(!payable(msg.sender).send(amount)){
            pendingReturns[msg.sender] = amount;
        }

        return true;
    }

    function auctionEnd() public {
         if(block.timestamp > endTime) {revert("the auction has not ended yet");}
         if(ended){ revert("the auction is already over");}

         ended = true;
         emit winnerAuction(highestBidder, highestBid);
         auctioneer.transfer(highestBid);
    }

}