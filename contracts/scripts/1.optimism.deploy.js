async function main() {
  const LZ_ENDPOINT = "0xbC6F6b680bc61e30dB47721c6D1c5cde19C1300d"; // for Optimism
  const LZ_FTM_CHAIN_ID = 10012, // use 12 for mainnet FTM, 10012 for testnet FTM
  const WETH = "0xbC6F6b680bc61e30dB47721c6D1c5cde19C1300d"; // testnet WETH
  const WEVE = "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1"; // testnet DAI

  // Load
  const [
    Velo,
    GaugeFactory,
    BribeFactory,
    PairFactory,
    Router,
    Library,
    VotingEscrow,
    RewardsDistributor,
    Voter,
    Minter,
    Reedemer,
    RedemptionReceiver
  ] = await Promise.all([
    ethers.getContractFactory("Velo"),
    ethers.getContractFactory("GaugeFactory"),
    ethers.getContractFactory("BribeFactory"),
    ethers.getContractFactory("PairFactory"),
    ethers.getContractFactory("Router"),
    ethers.getContractFactory("VelodromeLibrary"),
    ethers.getContractFactory("VotingEscrow"),
    ethers.getContractFactory("RewardsDistributor"),
    ethers.getContractFactory("Voter"),
    ethers.getContractFactory("Minter"),
    ethers.getContractFactory("Redeemer"),
    ethers.getContractFactory("RedemptionReceiver"),
  ])

  // Deploy contracts
  const [velo, gaugeFactory, bribeFactory, pairFactory] = await Promise.all([
    Velo.deploy(),
    GaugeFactory.deploy(),
    BribeFactory.deploy(),
    PairFactory.deploy()
  ])
  console.log('Velo\n', velo.address);
  console.log('GaugeFactory\n', gaugeFactory.address);
  console.log('BribeFactory\n', bribeFactory.address);
  console.log('PairFactory\n', pairFactory.address);
  const router = await Router.deploy(pairFactory.address, WETH); // 2nd arg is WETH
  console.log('Router\n', router.address);
  const library = await Library.deploy(router.address);
  console.log('VelodromeLibrary\n', library.address);
  const escrow = await VotingEscrow.deploy(velo.address);
  console.log('VotingEscrow\n', escrow.address);
  const distributor = await RewardsDistributor.deploy(escrow.address);
  console.log('RewardsDistributor\n', distributor.address);
  const voter = await Voter.deploy(escrow.address, pairFactory.address, gaugeFactory.address, bribeFactory.address);
  console.log('Voter\n', voter.address);
  const minter = await Minter.deploy(voter.address, escrow.address, distributor.address);
  console.log('Minter\n', minter.address);
  // TODO change to usdc.address, using velo for test simplicity now
  const redeemer = await Redeemer.deploy(WEVE, velo.address, velo.address);
  console.log('Redeemer\n', redeemer.address);
  const redemptionReceiver = await RedemptionReceiver.deploy(
    USDC,
    velo.address,
    LZ_FTM_CHAIN_ID,
    LZ_ENDPOINT
  );
  console.log('RedemptionReceiver\n', redemptionReceiver.address);

  // Configure contracts
  await Promise.all([
    velo.setRedeemer(redeemer.address),
    velo.setMinter(minter.address),
    escrow.setVoter(voter.address),
    distributor.setDepositor(minter.address),
  ])
  console.log("Configuration complete!")

  // testnet support functions to get WeVE to test accts
  // await voter.initialize(["0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83","0x04068da6c83afcfa0e13ba15a6696662335d5b75","0x321162Cd933E2Be498Cd2267a90534A804051b11","0x8d11ec38a3eb5e956b052f67da8bdc9bef8abf3e","0x82f0b8b456c1a451378467398982d4834b6829c1","0xdc301622e621166bd8e82f2ca0a26c13ad0be355","0x1E4F97b9f9F913c46F1632781732927B9019C68b", "0x29b0Da86e484E1C0029B56e817912d778aC0EC69", "0xae75A438b2E0cB8Bb01Ec1E1e376De11D44477CC", "0x7d016eec9c25232b01f23ef992d98ca97fc2af5a", "0x468003b688943977e6130f4f68f23aad939a1040","0xe55e19fb4f2d85af758950957714292dac1e25b2","0x4cdf39285d7ca8eb3f090fda0c069ba5f4145b37","0x6c021ae822bea943b2e66552bde1d2696a53fbb7","0x2a5062d22adcfaafbd5c541d4da82e4b450d4212","0x841fad6eae12c286d1fd18d1d525dffa75c7effe","0x5C4FDfc5233f935f20D2aDbA572F770c2E377Ab0","0xad996a45fd2373ed0b10efa4a8ecb9de445a4302", "0xd8321aa83fb0a4ecd6348d4577431310a6e0814d", "0x5cc61a78f164885776aa610fb0fe1257df78e59b", "0x10b620b2dbac4faa7d7ffd71da486f5d44cd86f9","0xe0654C8e6fd4D733349ac7E09f6f23DA256bF475","0x85dec8c4b2680793661bca91a8f129607571863d","0x74b23882a30290451A17c44f4F05243b6b58C76d","0xf16e81dce15b08f326220742020379b855b87df9", "0x9879abdea01a879644185341f7af7d8343556b7a","0x00a35FD824c717879BF370E70AC6868b95870Dfb","0xc5e2b037d30a390e62180970b3aa4e91868764cd", "0x10010078a54396F62c96dF8532dc2B4847d47ED3"], minter.address);
  // await minter.initialize(["0x5bDacBaE440A2F30af96147DE964CC97FE283305","0xa96D2F0978E317e7a97aDFf7b5A76F4600916021","0x95478C4F7D22D1048F46100001c2C69D2BA57380","0xC0E2830724C946a6748dDFE09753613cd38f6767","0x3293cB515Dbc8E0A8Ab83f1E5F5f3CC2F6bbc7ba","0xffFfBBB50c131E664Ef375421094995C59808c97","0x02517411F32ac2481753aD3045cA19D58e448A01","0xf332789fae0d1d6f058bfb040b3c060d76d06574","0xdFf234670038dEfB2115Cf103F86dA5fB7CfD2D2","0x0f2A144d711E7390d72BD474653170B201D504C8","0x224002428cF0BA45590e0022DF4b06653058F22F","0x26D70e4871EF565ef8C428e8782F1890B9255367","0xA5fC0BbfcD05827ed582869b7254b6f141BA84Eb","0x4D5362dd18Ea4Ba880c829B0152B7Ba371741E59","0x1e26D95599797f1cD24577ea91D99a9c97cf9C09","0xb4ad8B57Bd6963912c80FCbb6Baea99988543c1c","0xF9E7d4c6d36ca311566f46c81E572102A2DC9F52","0xE838c61635dd1D41952c68E47159329443283d90","0x111731A388743a75CF60CCA7b140C58e41D83635","0x0edfcc1b8d082cd46d13db694b849d7d8151c6d5","0xD0Bb8e4E4Dd5FDCD5D54f78263F5Ec8f33da4C95","0x9685c79e7572faF11220d0F3a1C1ffF8B74fDc65","0xa70b1d5956DAb595E47a1Be7dE8FaA504851D3c5","0x06917EFCE692CAD37A77a50B9BEEF6f4Cdd36422","0x5b0390bccCa1F040d8993eB6e4ce8DeD93721765"], [ethers.BigNumber.from("800000000000000000000000"),ethers.BigNumber.from("2376588000000000000000000"),ethers.BigNumber.from("1331994000000000000000000"),ethers.BigNumber.from("1118072000000000000000000"),ethers.BigNumber.from("1070472000000000000000000"),ethers.BigNumber.from("1023840000000000000000000"),ethers.BigNumber.from("864361000000000000000000"),ethers.BigNumber.from("812928000000000000000000"),ethers.BigNumber.from("795726000000000000000000"),ethers.BigNumber.from("763362000000000000000000"),ethers.BigNumber.from("727329000000000000000000"),ethers.BigNumber.from("688233000000000000000000"),ethers.BigNumber.from("681101000000000000000000"),ethers.BigNumber.from("677507000000000000000000"),ethers.BigNumber.from("676304000000000000000000"),ethers.BigNumber.from("642992000000000000000000"),ethers.BigNumber.from("609195000000000000000000"),ethers.BigNumber.from("598412000000000000000000"),ethers.BigNumber.from("591573000000000000000000"),ethers.BigNumber.from("587431000000000000000000"),ethers.BigNumber.from("542785000000000000000000"),ethers.BigNumber.from("536754000000000000000000"),ethers.BigNumber.from("518240000000000000000000"),ethers.BigNumber.from("511920000000000000000000"),ethers.BigNumber.from("452870000000000000000000")], ethers.BigNumber.from("100000000000000000000000000"));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
