// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract InternalEnergyAccountingContract {
    uint256 private etherPrice; 
    address public owner;

    struct Seller {
        address addr;
        uint256 energyOffered;
        uint256 desiredPrice;
    }
    Seller[] public allSellers;

    struct VerifiedSeller {
        address addr;
        uint256 energyOffered;
        uint256 desiredPrice;
    }
    mapping(uint256 => VerifiedSeller) public vSellers;
    address[] public vAddresses;
    uint256[] public vSEOs;
    uint256[] public vSOPs;

    struct Buyer {
        address addr;
        uint256 energyDemanded; 
        uint256 priceBid; 
        uint256 fundsCommitted; 
    }
    mapping(address => Buyer) public buyers; // Using mapping for F6/F7
    address[] public buyerLookup; // To track keys in the mapping

    struct VerifiedBuyer {
        address addr;
        uint256 energyDemanded;
        uint256 priceBid;
        uint256 fundsCommitted;
    }
    mapping(uint256 => VerifiedBuyer) public vBuyers;
    address[] public vBuyerAddr;
    uint256[] public vBEBs;
    uint256[] public vBBPs;
    uint256[] public vFCs; 

    uint256[] public paylist;

    constructor() {
        owner = msg.sender;
    }

    // F2: setRate
    function setRate(uint rate) public {
        require(msg.sender == owner, "Only owner can set the rate");
        etherPrice = rate;
    }

    // F3: CheckEtherEquiv
    function checkEtherEquiv(uint256 energyPrice) public view returns(uint256){
        return (energyPrice * 1e18) / etherPrice; //1 ETH = 1,000,000,000,000,000,000 Wei 
    }

    // F4: offers
    function submitOffers(uint256 SEO, uint256 SOP) public {
        allSellers.push(Seller(msg.sender, SEO, SOP));
    }

    // F5: verifiedOffers
    function verifiedOffers(address offerorAddress, uint256 SEO, uint256 SOP) public {
        bool found = false;
        for(uint i = 0; i < allSellers.length; i++){
            if(allSellers[i].addr == offerorAddress && allSellers[i].energyOffered == SEO && allSellers[i].desiredPrice == SOP){
                found = true;
                break;
            }
        }
        require(found, "Offer not found");

        uint256 id = vAddresses.length;
        vSellers[id] = VerifiedSeller(offerorAddress, SEO, SOP);
        vAddresses.push(offerorAddress);
        vSEOs.push(SEO);
        vSOPs.push(SOP);

        delete allSellers; 
    }

    // F6: bids
    function submitBid(uint256 BEB, uint256 BBP) public payable {
        uint256 dollarsSent = (msg.value * etherPrice) / 1e18;
        require(dollarsSent >= BBP, "Ether sent < Bid Price");

        buyers[msg.sender] = Buyer(msg.sender, BEB, BBP, msg.value);
        buyerLookup.push(msg.sender);
    }

    // F7: verifiedBids
    function verifiedBids(address bidderAddress, uint256 BEB, uint256 BBP) public {
        require(buyers[bidderAddress].addr == bidderAddress && buyers[bidderAddress].energyDemanded == BEB && buyers[bidderAddress].priceBid == BBP, "Bid mismatch");

        uint256 id = vBuyerAddr.length;
        vBuyers[id] = VerifiedBuyer(bidderAddress, BEB, BBP, buyers[bidderAddress].fundsCommitted);
        
        vBuyerAddr.push(bidderAddress);
        vBEBs.push(BEB);
        vBBPs.push(BBP);
        vFCs.push(buyers[bidderAddress].fundsCommitted);

        delete buyers[bidderAddress];
    }

    // F8: matching
    function matchDemandAndSupply() public {
        require(msg.sender == owner, "Only owner can run matching");

        for(uint i=0; i < vAddresses.length; i++){
            uint x = 0; 
            uint yy = 0; 
            uint pay = 0;

            for(uint j=0; j < vBuyerAddr.length; j++){
                if (vBBPs[j] < vSOPs[i]) {
                    x = 1;
                    break;
                }
                if(vBEBs[j] == 0) continue;

                if (vSEOs[i] < vBEBs[j]) {
                    pay = pay + (vBBPs[j] + vSOPs[i]) * vSEOs[i] * 1e18 / (2 * etherPrice);
                    vBEBs[j] -= vSEOs[i];
                    vSEOs[i] = 0;
                    break; 
                } else {
                    pay = pay + (vBBPs[j] + vSOPs[i]) * vBEBs[j] * 1e18 / (2 * etherPrice);
                    vSEOs[i] -= vBEBs[j];
                    vBEBs[j] = 0;
                    if(j == (vBuyerAddr.length - 1)) { 
                        yy = 1;
                        break;
                    }
                }
            }
            if (x > 0) break;
            paylist.push(pay);
            if (yy > 0) break;
        }
    }

    // F9: paySellers
    function paySellers() public {
        require(msg.sender == owner, "Only owner authorizes payment");
        for(uint i = 0; i < paylist.length; i++){
            if (paylist[i] > 0) {
                payable(vAddresses[i]).transfer(paylist[i]);
            } 
        }
    }
  
    // F10: refundBuyers
    function refundBuyers() public {
        require(msg.sender == owner, "Only owner authorizes refund");
        for(uint i = 0; i < vBuyerAddr.length; i++){
            if(vBEBs[i] > 0) {
                 payable(vBuyerAddr[i]).transfer(vFCs[i]);
            }
        }
    }

}
