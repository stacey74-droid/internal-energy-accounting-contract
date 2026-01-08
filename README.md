# Internal Energy Accounting Contract

Create a contract that maintains a ledger of debits and credits for energy consumption and contribution among a small group of users, 
settling balances upon request.

---

### 🤝Peer-to-Peer (P2P) Internal Energy Accounting Contract
Each peer within the grid has an onsite smart meter that is connected to a smart contract. It enables prosumers (sellers) and 
consumers (buyers) to trade locally generated energy in a transparent, automated, and secure marketplace. 

### 🤌Project Summary
The Internal Energy Accounting Contract acts as an automated clearinghouse for local energy grids. It manages the entire lifecycle 
of an energy transaction—from price setting and bid submission to matching supply with demand and executing financial settlements. 
By utilizing blockchain technology, the project eliminates the need for a central intermediary, reducing costs and ensuring that all 
participants are paid fairly based on market-clearing prices.

---

### ☑️Features
1. **SET RATE**

The system allows the network administrator to set a real-time exchange rate between USD ($) and Ether (ETH). This ensures that energy 
prices remain stable in fiat terms while utilizing the security of the Ethereum blockchain for payments.

2. **SUBMIT OFFER**

Sellers (prosumers) can submit their available energy capacity (MWh) and their minimum desired price ($) directly to the ledger.

3. **SUBMIT BID**

Buyers (consumers) submit how much energy capacity they want to buy and their maximum price they're willing to pay. The buyer must send 
money to the contract at the same time they make their bid to guarantee that funds are available for the seller once a match is made.
This helps prevent people making spam bids and mess up with the market prices.

4. **VERIFICATION**

The contract includes a verification layer that cross-references raw market data with verified entries. This prevents data corruption 
and ensures that only valid, authorized offers enter the matching engine.

5. **AUTOMATED AUCTION MECHANISM/MATCH MARKET**

The smart contract automatically pairs buyers and sellers. It compares all sellers(ascending by price - because from perspective of buyers
they would want the cheapest offer) and all buyers (descending by price - because from perspective of sellers they would want the most 
profitable bid) and then it finds the optimal point where supply meets demand and sets a clearing price, ensuring both the buyer and seller 
benefit from the trade. 

6. **INSTANT OF FINANCIAL PAYOUT/PAY SELLERS**

The contract monitors real-time smart meter data to verify that the physical energy was actually transferred. Once delivery is verified
the contract authorises the transfer of the held funds to the sellers.

7. **REFUND BUYERS**

If a buyer’s bid is not fully satisfied or if the final clearing price is lower than their initial bid, the contract automatically 
calculates and returns the surplus ETH to the buyer. 

---

### 👩‍💻Implementation

A high level diagram taken from 🔗Source shows how the contract will work: 

![smart contract-based double auction P2P energy trading scheme](images/p2p_energy_trading_scheme.png)

The 🔗Source also shows the matching algorithm in a flowchart: 

![flowchart](images/flowchart.png)

| **Algorithm 1: Smart Contract-Based Energy Double Auction Mechanism** |

```
F1: Constructor
  //Executed at contract deployment
  //Assigns the address of the contract deployer to a variable “owner”
F2: setRate
  input: Ether price in $
  require: function caller = owner
  rate = Ether price
F3: CheckEtherEquiv
 input: Energy price in $/MWh
 output: Energy price * 10^18/rate  
F4: offers
 input: Seller’s energy offer (SEO) in MWh; Seller’s offer price (SOP) in $
 store in ‘sellers’ mapping
F5: verifiedOffers
 input: account address of offeror; (SEO); (SOP)
 require: SEO & SOP in ‘sellers’ match, for all account addresses.
 populate a new mapping ‘vSellers’ with the newly ordered account addresses, SEOs & SOPs
 create an array each for account addresses, SEOs & SOPs
 remove data from ‘sellers’ mapping
F6: bids
 require: bid price is equal to the amount of ether sent multiplied by rate
 input: buyer’s energy bid (BEB) in MWh; buyer’s bid price (BBP) in $
 store in ‘buyers’ mapping
//The ‘buyers’ mapping is sent out for re-ordering in descending order of BBPs then the new list is sent back to the smart contract for verification. Re-ordering within the smart contract is expensive.
F7: verifiedBids
 input: account address of bidder; BEB and BBP
 require: BEB and BBP in ‘buyers’ match, for all account addresses.
 populate a new mapping with the newly ordered account addresses, BEBs and BBPs
 create an array each for account addresses, BEB and BBP
 remove data from ‘buyers’ mapping
F8: matching
 require: function caller = owner
 for each seller
   x = 0; yy = 0; pay = 0;
   for each buyer
     if BBP < SOP, x = 1; break out of loop;
     if BEB = 0, continue to next buyer
     if SEO < BEB
       BEB = BEB − SEO
       pay = pay + (BBP + SOP) * SEO * 10^18/(2*rate)
       SEO = 0; break out of loop;
     else
       SEO = SEO − BEB
       pay = pay + (BBP + SOP) * BEB * 10^18/(2*rate)
       BEB = 0
       if last buyer, yy = 1; break out of loop;
   end for
   if x > 0, break out of loop;
   paylist.push(pay)
   if yy > 0, break out of loop;
  end for
F9: paySellers
  require: function caller = owner
  for each element in array
    pay corresponding seller
  end for
F10: refundBuyers
  require: function caller = owner
  for each bidder,
    if unsuccessful
      refund committed funds
  end for
```

### 💻Tech stack

| **Technology** | **Name** |
| :--- | :--- |
| _Programming Language_ | `Solidity` |
| _IDE_ | `Remix` |
| _Version Control_ | `GitHub` |

### 🔴DEMO

Done in class

### 🔗Source
[1] https://www.mdpi.com/1996-1073/15/11/4084 (Towards Blockchain-Based Energy Trading: A Smart Contract Implementation of Energy Double Auction and Spinning Reserve Trading
by Uyikumhe Damisa 1,2,*ORCID,Nnamdi I. Nwulu 1,2ORCID andPierluigi Siano 2,3ORCID)

---
_Submission: Project code and powerpoint_