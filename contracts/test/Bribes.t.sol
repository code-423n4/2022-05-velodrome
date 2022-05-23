pragma solidity 0.8.13;

import './BaseTest.sol';

contract BribesTest is BaseTest {
    VotingEscrow escrow;
    GaugeFactory gaugeFactory;
    BribeFactory bribeFactory;
    Voter voter;
    RewardsDistributor distributor;
    Minter minter;
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
        mintLR(owners, amounts);
        escrow = new VotingEscrow(address(VELO));
        deployPairFactoryAndRouter();
        deployPairWithOwner(address(owner));

        // deployVoter()
        gaugeFactory = new GaugeFactory(address(factory));
        bribeFactory = new BribeFactory();
        voter = new Voter(address(escrow), address(factory), address(gaugeFactory), address(bribeFactory));

        escrow.setVoter(address(voter));

        // deployMinter()
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

        address[] memory claimants = new address[](0);
        uint[] memory amounts1 = new uint[](0);
        minter.initialize(claimants, amounts1, 0);

        // USDC - FRAX stable
        gauge = Gauge(voter.createGauge(address(pair)));
        bribe = Bribe(gauge.bribe());
    }

    function testCanSetExternalBribe() public {
        // create a bribe
        LR.approve(address(bribe), TOKEN_1);
        bribe.notifyRewardAmount(address(LR), TOKEN_1);
        assertEq(LR.balanceOf(address(bribe)), TOKEN_1);

        // fwd phases
        vm.warp(block.timestamp + 1 days); // bribes phase -> votes phase
        vm.roll(block.number + 1);
        vm.warp(block.timestamp + 5 days); // votes phase -> rewards phase
        vm.roll(block.number + 1);

        // deliver bribe
        vm.prank(address(voter));
        gauge.deliverBribes();
        assertEq(LR.balanceOf(address(gauge)), TOKEN_1);
    }

    function testEmissions() public {
        // vote
        VELO.approve(address(escrow), TOKEN_1);
        escrow.create_lock(TOKEN_1, 4 * 365 * 86400);
        vm.warp(block.timestamp + 1);

        address[] memory pools = new address[](1);
        pools[0] = address(pair);
        uint256[] memory weights = new uint256[](1);
        weights[0] = 10000;
        voter.vote(1, pools, weights);

        // and deposit into the gauge!
        pair.approve(address(gauge), 1e9);
        gauge.deposit(1e9, 1);

        vm.warp(block.timestamp + 12 hours); // still prior to epoch start
        vm.roll(block.number + 1);
        assertEq(uint(gauge.getVotingStage(block.timestamp)), uint(Gauge.VotingStage.BribesPhase));

        vm.warp(block.timestamp + 12 hours); // start of epoch
        vm.roll(block.number + 1);
        assertEq(uint(gauge.getVotingStage(block.timestamp)), uint(Gauge.VotingStage.VotesPhase));

        vm.expectRevert(abi.encodePacked("cannot claim during votes period"));
        voter.distro();

        vm.warp(block.timestamp + 5 days); // votes period over
        vm.roll(block.number + 1);

        vm.warp(2 weeks + 1); // emissions start
        vm.roll(block.number + 1);

        minter.update_period();
        distributor.claim(1); // yay this works

        vm.warp(block.timestamp + 1 days); // next votes period start
        vm.roll(block.number + 1);

        // get a bribe
        owner.approve(address(LR), address(bribe), TOKEN_1);
        bribe.notifyRewardAmount(address(LR), TOKEN_1);

        vm.warp(block.timestamp + 5 days); // votes period over
        vm.roll(block.number + 1);
        voter.distro(); // bribe gets deposited in the gauge
        assertGt(gauge.earned(address(LR), address(this)), 0);

        address[] memory claimTokens = new address[](1);
        claimTokens[0] = address(LR);
        gauge.getReward(address(this), claimTokens);
    }
}