//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

/**
 * @title A sample Raffle Contract
 * @author Sivasuryaa
 * @notice This contract is for creating a sample raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */

contract Raffle {
    /** Errors */
    error Raffle__sendMoreEthToEnterRaffle();

    uint256 private immutable i_entraceFee;

    constructor(uint256 entraceFee) {
        i_entraceFee = entraceFee;
    }

    function enterRaffle() public payable {
        //Check for entrance fee.
        if (msg.value < i_entraceFee) {
            revert Raffle__sendMoreEthToEnterRaffle();
        }
    }

    function pickWinner() public {}

    /** Getter Functions */
    function getEntranceFee() external view returns (uint256) {
        return i_entraceFee;
    }
}
