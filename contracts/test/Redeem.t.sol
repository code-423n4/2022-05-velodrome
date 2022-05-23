pragma solidity 0.8.13;

import "./BaseTest.sol";
import "./utils/TestEndpoint.sol";

contract RedeemTest is BaseTest {
    TestEndpoint endpoint;
    RedemptionSender sender;
    RedemptionReceiver receiver;

    uint256 public constant redeemableUSDC = 10e6 * 1e6;
    uint256 public constant redeemableVELO = 10e6 * 1e18;
    uint256 public constant eligibleWEVE = 1e9 * 1e18;

    function setUp() public {
        deployOwners();
        deployCoins();
        mintStables();

        endpoint = new TestEndpoint(12); // mock LZ endpoint sending from Fantom
        receiver = new RedemptionReceiver(
            address(USDC),
            address(VELO),
            12,
            address(endpoint)
        );
        sender = new RedemptionSender(
            address(WEVE),
            11,
            address(endpoint),
            address(receiver)
        );

        USDC.mint(address(this), redeemableUSDC);
        USDC.approve(address(receiver), redeemableUSDC);

        VELO.setRedemptionReceiver(address(receiver));
        receiver.initializeReceiverWith(
            address(sender),
            eligibleWEVE,
            redeemableUSDC,
            redeemableVELO
        );
    }

    function testRedemption(address redeemer, uint128 amount) public {
        vm.assume(redeemer != address(0) && 1 < amount && amount <= eligibleWEVE);

        uint256 beforeUSDC = USDC.balanceOf(redeemer);
        uint256 beforeVELO = VELO.balanceOf(redeemer);

        WEVE.mint(redeemer, amount);
        vm.startPrank(redeemer);
        WEVE.approve(address(sender), amount);
        sender.redeemWEVE(amount / 2, address(0), bytes(""));
        sender.redeemWEVE(amount / 2, address(0), bytes(""));
        vm.stopPrank();

        assertApproxEqAbs(
            USDC.balanceOf(redeemer) - beforeUSDC,
            (amount * redeemableUSDC) / eligibleWEVE,
            1
        );
        assertApproxEqAbs(
            VELO.balanceOf(redeemer) - beforeVELO,
            (amount * redeemableVELO) / eligibleWEVE,
            1
        );
    }
}
