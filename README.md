#HarbergerLicenseTrust

A system for administering non-fungible ERC721 tokens that represent Harberger licenses attaching to real-world assets.

This work-in-progress contract (ERC721HarbergerLicense.sol) can facilitate the decentralized administration of interests in property that are similar to those described in Chapter 1 of Eric Posner and Glen Weyl's book Radical Markets.  This is intended to advance our understanding of Harberger taxation and licensing in connection with blockchain technology, and/or spur research and experimentation leading to more fair and efficient economic resource management.

Feel free to mess around with this system!  But do so at your own risk!  This code is neither finished nor audited and you should understand exactly what you are doing before you deploy to the mainnet and/or draw up real licenses or contracts that rely on it.

High level intro on how one might interact with the contract:

1. Mint a unique ERC721 token corresponding to a Harberger license on a real asset.  Set the turnover rate (i.e., the ongoing fees to hold the license), the value of the Harberger license, and the beneficiary of the fees.

2. Draw up a real-world contract entitling the holder of that ERC721 token to a Harberger license to occupy, possess, or use the real asset.  This step must occur off-chain.  Lawyer not included :).

3. A yearly fee equaling the defined turnover rate (the Harberger tax) must be paid by the token holder/licensee to the contract.  The fee flows to the beneficiary chosen by the licensor.

4. As often as desired, the token holder may update her self-assessed license value, thus changing the amount she must pay to hold the license.

5. When fees are not paid, "equity" in the Harberger license equal to the amount of the unpaid fees reverts to the beneficiary of the fees.  It may be bought back by the token holder or a new purchaser, by paying back-fees.

6. Anyone may transfer any Harberger license token to himself (i.e., force a sale) by paying its self-assessed value to the contract, which then forwards that amount to the former holder.  
