// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "LayerZero/interfaces/ILayerZeroEndpoint.sol";
import "LayerZero/interfaces/ILayerZeroReceiver.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IVelo.sol";

/// @notice Part 2 of 2 in the WeVE (FTM) -> USDC + VELO (OP) redemption process
/// This contract is responsible for receiving the LZ message and distributing USDC + VELO
contract RedemptionReceiver is ILayerZeroReceiver {
    IERC20 public immutable USDC;
    IVelo public immutable VELO;
    uint16 public immutable fantomChainId; // 12 for FTM, 10012 for FTM testnet
    address public immutable endpoint;
    address public immutable deployer;

    constructor(
        address _usdc,
        address _velo,
        uint16 _fantomChainId,
        address _endpoint
    ) {
        require(_fantomChainId == 12 || _fantomChainId == 10012, "CHAIN_ID_NOT_FTM");
        USDC = IERC20(_usdc);
        VELO = IVelo(_velo);
        fantomChainId = _fantomChainId;
        endpoint = _endpoint;
        deployer = msg.sender;
    }

    address public fantomSender;
    uint256 public eligibleWEVE;
    uint256 public redeemableUSDC;
    uint256 public redeemableVELO;

    function initializeReceiverWith(
        address _fantomSender,
        uint256 _eligibleWEVE,
        uint256 _redeemableUSDC,
        uint256 _redeemableVELO
    ) external {
        require(msg.sender == deployer, "ONLY_DEPLOYER");
        require(fantomSender == address(0), "ALREADY_INITIALIZED");
        require(
            USDC.transferFrom(msg.sender, address(this), _redeemableUSDC),
            "USDC_TRANSFER_FAILED"
        );
        require(
            VELO.mintToRedemptionReceiver(_redeemableVELO),
            "VELO_MINT_FAILED"
        );
        fantomSender = _fantomSender;
        eligibleWEVE = _eligibleWEVE;
        redeemableUSDC = _redeemableUSDC;
        redeemableVELO = _redeemableVELO;
    }

    uint256 public redeemedWEVE;

    function previewRedeem(uint256 amountWEVE)
        public
        view
        returns (uint256 shareOfUSDC, uint256 shareOfVELO)
    {
        // pro rata USDC
        shareOfUSDC = (amountWEVE * redeemableUSDC) / eligibleWEVE;
        // pro rata VELO
        shareOfVELO = (amountWEVE * redeemableVELO) / eligibleWEVE;
    }

    function lzReceive(
        uint16 srcChainId,
        bytes memory srcAddress,
        uint64,
        bytes memory payload
    ) external override {
        require(fantomSender != address(0), "NOT_INITIALIZED");
        require(
            msg.sender == endpoint &&
                srcChainId == fantomChainId &&
                addressFromPackedBytes(srcAddress) == fantomSender,
            "UNAUTHORIZED_CALLER"
        );

        (address redemptionAddress, uint256 amountWEVE) = abi.decode(
            payload,
            (address, uint256)
        );

        require(
            (redeemedWEVE += amountWEVE) <= eligibleWEVE,
            "cannot redeem more than eligible"
        );
        (uint256 shareOfUSDC, uint256 shareOfVELO) = previewRedeem(amountWEVE);

        require(
            USDC.transfer(redemptionAddress, shareOfUSDC),
            "USDC_TRANSFER_FAILED"
        );
        require(
            VELO.transfer(redemptionAddress, shareOfVELO),
            "VELO_TRANSFER_FAILED"
        );
    }

    function addressFromPackedBytes(bytes memory toAddressBytes)
        public
        pure
        returns (address toAddress)
    {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            toAddress := mload(add(toAddressBytes, 20))
        }
    }
}
