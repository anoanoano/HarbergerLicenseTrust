#HarbergerLicenseTrust

A network of non-fungible ERC721 tokens that represent Harberger licenses attaching to off-chain assets.

The work-in-progress contract (ERC721HarbergerLicense.sol) can facilitate the decentralized administration of interests in property similar to those described in Eric Posner and Glen Weyl's book Radical Markets.  This is intended to advance understanding of Harberger taxation and licensing in connection with blockchain technology, to serve as a prototype/POC back-end for Harberger-licensed asset ecosystems, and/or to spur further research and experimentation concerning efficient, monopoly-resistant property regimes.

Feel free to mess around, but do so at your own risk!  This code is not finished or audited.

High level intro on how to interact with the contract:

1. Mint a unique ERC721 token corresponding to a Harberger license on a real asset.  Set the turnover rate (i.e., the ongoing fees to hold the license), the value of the Harberger license, and the beneficiary of the fees.

2. Draw up a real-world contract entitling the holder of that unique ERC721 token to a Harberger license to occupy, possess, or otherwise use an off-chain asset, subject to a periodic property tax based on a self-assessed value, and claimable by anyone for that self-assessed value.  The off-chain asset could be physical or virtual.   

3. A yearly fee equaling the defined turnover rate (the Harberger tax) must be paid by the token holder/licensee to the contract.  The fee flows to the beneficiary chosen when the token was minted.  (As of 7/27/18 the turnover rate starts at a rate which you define when you mint a token; but after the first forced acquisition, it is calculated as the acquisition-per-year rate, recalculated each second.)   

4. As often as desired, the token holder may update her self-assessed license value, thus changing the amount she must pay to hold the license.

5. When fees are not paid, "equity" in the Harberger license equal to the amount of the unpaid fees reverts to the beneficiary of the fees.  It may be bought back by the token holder or a new purchaser, by paying back-fees.  If it is not bought back, then at the time of the next transfer, a portion of the transfer sum corresponding to the unpaid fees goes to the fee beneficiary, instead of the token holder.

6. Anyone may acquire a Harberger license token without the owner's permission (i.e., force a sale) by paying its self-assessed value to the contract, which then forwards that amount to the former holder (and or fee beneficiary, to the extent back taxes are owed).  
