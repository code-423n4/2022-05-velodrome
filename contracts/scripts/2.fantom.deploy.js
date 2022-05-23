async function main() {
  const WEVE = "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1"; // WEVE
  const LZ_ENDPOINT = "0xbC6F6b680bc61e30dB47721c6D1c5cde19C1300d"; // for Fantom
  const RECEIVER_ADDRESS = ""; // on Optimism

  const RedemptionSender = await ethers.getContractFactory("RedemptionSender");

  const redemptionSender = await RedemptionSender.deploy(
    WEVE,
    10001, // use 11 for mainnet, 10011 for testnet
    LZ_ENDPOINT,
    RECEIVER_ADDRESS
  );
  console.log('RedemptionSender\n', redemptionSender.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
