# Velodrome contest details
- $71,250 USDC main award pot
- $3,750 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-05-velodrome-finance-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts May 23, 2022 20:00 UTC
- Ends May 30, 2022 19:59 UTC

## Contest Scope

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

### New Formula
  
  The only new formula we introduce is for the emissions schedule:

  $\frac{1}{2} * weekly * (\frac{veTotal}{veloTotal})^3$

  where

  $veTotal$ is the total locked supply of VELO and

  $veloTotal$ is the total supply of VELO

### ERC-20 Standard 

  VELO is the native token of Velodrome and does conform to the ERC-20 standard

## Our Unique Approach

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

## Areas of Concern

  As we're not changing any of the core swap logic, the bulk of our security concerns relate to the native token emissions, governance, and distribution:
  - `Gauge.sol` and `Bribe.sol`, which introduce new logic related to how external bribes and voting work
  - `VotingEscrow.sol`, which adds compatibility with OZ/Comp-style governance tools like Tally
  - `RedemptionSender.sol` and `RedemptionReceiver.sol` which both use LayerZero for cross-chain messaging
