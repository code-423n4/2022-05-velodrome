pragma solidity 0.8.13;

interface IBribe {
    function notifyRewardAmount(address token, uint amount) external;
    function setGauge(address _gauge) external;
    function getEpochStart(uint timestamp) external view returns (uint);
    function deliverReward(address token, uint epochStart) external returns (uint);
    function rewardsListLength() external view returns (uint);
    function rewards(uint i) view external returns (address);
    function addRewardToken(address token) external;
    function swapOutRewardToken(uint i, address oldToken, address newToken) external;
}
