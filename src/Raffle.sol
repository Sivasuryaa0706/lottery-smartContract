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
    address payable[] private s_players;
    // @dev Duration of the lottery in seconds.
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;

    /** Events */
    event RaffleEntered(address indexed player);

    constructor(uint256 entraceFee, uint256 interval) {
        i_entraceFee = entraceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        //Check for entrance fee.
        if (msg.value < i_entraceFee) {
            revert Raffle__sendMoreEthToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
    }

    /** Getter Functions */
    function getEntranceFee() external view returns (uint256) {
        return i_entraceFee;
    }
}
