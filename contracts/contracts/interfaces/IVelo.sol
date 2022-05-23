pragma solidity 0.8.13;

interface IVelo {
    function approve(address spender, uint value) external returns (bool);
    function mint(address, uint) external;
    function mintToRedemptionReceiver(uint) external returns (bool);
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
}
