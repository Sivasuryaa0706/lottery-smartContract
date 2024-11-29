//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

/**
 * @title A sample Raffle Contract
 * @author Sivasuryaa
 * @notice This contract is for creating a sample raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */

contract Raffle {
    uint256 private immutable i_entraceFee;

    constructor(uint256 entraceFee) {
        i_entraceFee = entraceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}

    /** Getter Functions */
    function getEntranceFee() external view returns (uint256) {
        return i_entraceFee;
    }
}
