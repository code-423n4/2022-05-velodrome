pragma solidity 0.8.13;

import "./BaseTest.sol";

contract KillGaugesTest is BaseTest {
  VotingEscrow escrow;
  GaugeFactory gaugeFactory;
  BribeFactory bribeFactory;
  Voter voter;
  RewardsDistributor distributor;
  Minter minter;
  TestStakingRewards staking;
  Gauge gauge;
  Bribe bribe;

  function setUp() public {
    deployOwners();
    deployCoins();
    mintStables();
    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 2e25;
    amounts[1] = 1e25;
    amounts[2] = 1e25;
    mintVelo(owners, amounts);
    escrow = new VotingEscrow(address(VELO));

    VELO.approve(address(escrow), 100 * TOKEN_1);
    escrow.create_lock(100 * TOKEN_1, 4 * 365 * 86400);
    vm.roll(block.number + 1);

    deployPairFactoryAndRouter();

    deployPairWithOwner(address(owner));

    gaugeFactory = new GaugeFactory(address(factory));
    bribeFactory = new BribeFactory();
    voter = new Voter(
      address(escrow),
      address(factory),
      address(gaugeFactory),
      address(bribeFactory)
    );

    escrow.setVoter(address(voter));

    distributor = new RewardsDistributor(address(escrow));

    minter = new Minter(address(voter), address(escrow), address(distributor));
    distributor.setDepositor(address(minter));
    VELO.setMinter(address(minter));
    address[] memory tokens = new address[](4);
    tokens[0] = address(USDC);
    tokens[1] = address(FRAX);
    tokens[2] = address(DAI);
    tokens[3] = address(VELO);
    voter.initialize(tokens, address(minter));

    VELO.approve(address(gaugeFactory), 15 * TOKEN_100K);
    address gaugeAddr = voter.createGauge(address(pair));

    staking = new TestStakingRewards(address(pair), address(VELO));

    address gaugeAddress = voter.gauges(address(pair));
    address bribeAddress = voter.bribes(gaugeAddress);
    gauge = Gauge(gaugeAddress);
    bribe = Bribe(bribeAddress);
  }

  function testEmergencyCouncilCanKillAndReviveGauges() public {
    address gaugeAddress = address(gauge);

    // emergency council is owner
    voter.killGauge(gaugeAddress);
    assertFalse(voter.isAlive(gaugeAddress));

    voter.reviveGauge(gaugeAddress);
    assertTrue(voter.isAlive(gaugeAddress));
  }

  function testFailCouncilCannotKillNonExistentGauge() public {
    voter.killGauge(address(0xDEAD));
  }

  function testFailNoOneElseCanKillGauges() public {
    address gaugeAddress = address(gauge);
    vm.prank(address(owner2));
    voter.killGauge(gaugeAddress);
  }

  function testKilledGaugeCannotDeposit() public {
    USDC.approve(address(router), USDC_100K);
    FRAX.approve(address(router), TOKEN_100K);
    router.addLiquidity(address(FRAX), address(USDC), true, TOKEN_100K, USDC_100K, TOKEN_100K, USDC_100K, address(owner), block.timestamp);

    address gaugeAddress = address(gauge);
    voter.killGauge(gaugeAddress);

    uint256 supply = pair.balanceOf(address(owner));
    pair.approve(address(gauge), supply);
    vm.expectRevert(abi.encodePacked(""));
    gauge.deposit(supply, 1);
  }

  function testKilledGaugeCanWithdraw() public {
    USDC.approve(address(router), USDC_100K);
    FRAX.approve(address(router), TOKEN_100K);
    router.addLiquidity(address(FRAX), address(USDC), true, TOKEN_100K, USDC_100K, TOKEN_100K, USDC_100K, address(owner), block.timestamp);

    address gaugeAddress = address(gauge);

    uint256 supply = pair.balanceOf(address(owner));
    pair.approve(address(gauge), supply);
    gauge.deposit(supply, 1);

    voter.killGauge(gaugeAddress);

    gauge.withdrawToken(supply, 1); // should be allowed
  }

  function testKilledGaugeCannotUpdate() public {
    vm.warp(block.timestamp + 86400 * 7 * 2);
    vm.roll(block.number + 1);
    minter.update_period();
    voter.updateGauge(address(gauge));
    uint256 claimable = voter.claimable(address(gauge));
    VELO.approve(address(staking), claimable);
    staking.notifyRewardAmount(claimable);
    address[] memory gauges = new address[](1);
    gauges[0] = address(gauge);
    
    voter.killGauge(address(gauge));

    vm.expectRevert(abi.encodePacked(""));
    voter.updateFor(gauges);
  }

  function testKilledGaugeCannotDistro() public {
    vm.warp(block.timestamp + 86400 * 7 * 2);
    vm.roll(block.number + 1);
    minter.update_period();
    voter.updateGauge(address(gauge));
    uint256 claimable = voter.claimable(address(gauge));
    VELO.approve(address(staking), claimable);
    staking.notifyRewardAmount(claimable);
    address[] memory gauges = new address[](1);
    gauges[0] = address(gauge);
    voter.updateFor(gauges);

    voter.killGauge(address(gauge));

    vm.expectRevert(abi.encodePacked(""));
    voter.distro();
  }
}
