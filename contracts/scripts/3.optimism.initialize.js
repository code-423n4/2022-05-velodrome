async function main() {
  const RECEIVER_ADDRESS = "" // On Optimism
  const SENDER_ADDRESS = "" // On Fantom
  const ELIGIBLE_WEVE = ethers.BigNumber.from("");
  const REDEEMABLE_USDC = ethers.BigNumber.from("");
  const REDEEMABLE_VELO = ethers.BigNumber.from("");

  const RedemptionReceiver = await ethers.getContractFactory("RedemptionReceiver");

  const receiver = await RedemptionReceiver.attach(RECEIVER_ADDRESS);
  await receiver.initializeReceiverWith(
    SENDER_ADDRESS,
    ELIGIBLE_WEVE,
    REDEEMABLE_USDC,
    REDEEMABLE_VELO
  );
  console.log(`RedemptionSender at ${receiver.address} configured!`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
