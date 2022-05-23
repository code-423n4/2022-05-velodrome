# ✨ So you want to sponsor a contest

This `README.md` contains a set of checklists for our contest collaboration.

Your contest will use two repos: 
- **a _contest_ repo** (this one), which is used for scoping your contest and for providing information to contestants (wardens)
- **a _findings_ repo**, where issues are submitted. 

Ultimately, when we launch the contest, this contest repo will be made public and will contain the smart contracts to be reviewed and all the information needed for contest participants. The findings repo will be made public after the contest is over and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the contest sponsor (⭐️)**.

---

# Contest setup

## ⭐️ Sponsor: Provide contest details

Under "SPONSORS ADD INFO HERE" heading below, include the following:

- [ ] Name of each contract and:
  - [ ] source lines of code (excluding blank lines and comments) in each
  - [ ] external contracts called in each
  - [ ] libraries used in each
- [ ] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [ ] Does the token conform to the ERC-20 standard? In what specific ways does it differ?
- [ ] Describe anything else that adds any special logic that makes your approach unique
- [ ] Identify any areas of specific concern in reviewing the code
- [ ] Add all of the code to this repo that you want reviewed
- [ ] Create a PR to this repo with the above changes.

---

# Contest prep

## ⭐️ Sponsor: Contest prep
- [ ] Make sure your code is thoroughly commented using the [NatSpec format](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html#natspec-format).
- [ ] Modify the bottom of this `README.md` file to describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the C4 Wardens should keep in mind when reviewing. ([Here's a well-constructed example.](https://github.com/code-423n4/2021-06-gro/blob/main/README.md))
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 8 hours prior to contest start time.**
- [ ] Ensure that you have access to the _findings_ repo where issues will be submitted.
- [ ] Promote the contest on Twitter (optional: tag in relevant protocols, etc.)
- [ ] Share it with your own communities (blog, Discord, Telegram, email newsletters, etc.)
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# Velodrome contest details
- $71,250 USDC main award pot
- $3,750 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-05-velodrome-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts May 23, 2022 20:00 UTC
- Ends May 30, 2022 19:59 UTC

This repo will be made public before the start of the contest. (C4 delete this line when made public)

- [x] Name of each contract and:
  - [ ] external contracts called in each
  - [ ] libraries used in each

  Native Token
  - `Velo.sol` (62 lines)
  - `VotingEscrow.sol` (868 lines, lib: Base64)

  Pair
  - `Pair.sol` (416 lines, lib: Math)
  - `PairFees.sol` (23 lines)
  - `factories/PairFactory.sol` (82 lines)
  - `Router.sol` (370 lines, lib: Math)
  - `VelodromeLibrary.sol` (89 lines)

  Emissions
  - `RewardsDistributor.sol` (260 lines, lib: Math)
  - `Minter.sol` (111 lines; lib: Math)

  Voting
  - `Gauge.sol` (545 lines, lib: Math)
  - `factories/GaugeFactory.sol` (26 lines)
  - `Bribe.sol` (85 lines)
  - `factories/BribeFactory.sol` (9 lines)
  - `Voter.sol` (304 lines, lib: Math)

  Governance
  - `VeloGovernor.sol` (50 lines, lib: L2Governor governance)

  Redemption (WeVE -> VELO)
  - `redeem/RedemptionSender.sol` (44 lines, lib: LayerZero)
  - `redeem/RedemptionReceiver.sol` (99 lines, lib: LayerZero)

- [x] Describe any novel or unique curve logic or mathematical models implemented in the contracts
  
  The only new formula we introduce is for the emissions schedule:
  $\frac{1}{2} * weekly * (\frac{veTotal}{veloTotal})^3$
  where

  $veTotal$ is the total locked supply of VELO and

  $veloTotal$ is the total supply of VELO

- [x] Does the token conform to the ERC-20 standard? In what specific ways does it differ?

  VELO is the native token of Velodrome and does conform to the ERC-20 standard

- [x] Describe anything else that adds any special logic that makes your approach unique

  **Gauges/Bribes/Voting**
  - Staggered epoch for Gauges/Bribes to ensure rewards go to the right people
  - Added Compound-style weighted NFT governance for killing "bad" gauges. This governance uses block.timestamp instead of block.number because it's on an L2
  - Removed veNFT "boost" for LP staking
  - Gauges can be added for any address for emergency DAO
  - Removed negative voting

  **Emissions**
  - Updated emissions schedule
  - Added core team emissions

  **Pair**
  - Variable fees for stable/volatile pairs

  **Distribution**
  - Added two "redemption" contracts for WeVE (veDAO token) -> VELO+USDC which uses LayerZero

- [x] Identify any areas of specific concern in reviewing the code

  As we're not changing any of the core swap logic, the bulk of our security concerns relate to the native token emissions, governance, and distribution:
  - `Gauge.sol` and `Bribe.sol`, which introduce new logic related to how external bribes and voting work
  - `VotingEscrow.sol`, which adds compatibility with OZ/Comp-style governance tools like Tally
  - `RedemptionSender.sol` and `RedemptionReceiver.sol` which both use LayerZero for cross-chain messaging

- [x] Add all of the code to this repo that you want reviewed


- [x] Create a PR to this repo with the above changes.
