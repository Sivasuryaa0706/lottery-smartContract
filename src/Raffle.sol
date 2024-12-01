//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle Contract
 * @author Sivasuryaa
 * @notice This contract is for creating a sample raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */

contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle__sendMoreEthToEnterRaffle();
    error Raffle__transferFailed();
    error Raffle_RaffleNotOpen();

    /* Type Declarations */
    enum RaffleState {
        OPEN, //0
        CALCULATING //1
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entraceFee;
    address payable[] private s_players;
    // @dev Duration of the lottery in seconds.
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /* Events */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 entraceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entraceFee = entraceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        //Check for entrance fee.
        if (msg.value < i_entraceFee) {
            revert Raffle__sendMoreEthToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle_RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    /* Automation */
    /* Function to check whether updateUpKeep needs to be called to pick a winner
     * 1. Check if Enough time is passed
     * 2. Lottery is open
     * 3. The contract has ETH(has players)
     */
    function checkUpKeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = ((block.timestamp - s_lastTimeStamp) >=
            i_interval);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "");
    }

    function performUpKeep(bytes calldata /* performData */) external {
        (bool upKeepNeeded, ) = checkUpKeep("");
        if (!upKeepNeeded) {
            revert();
        }
        s_raffleState = RaffleState.CALCULATING;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });
        //Get a random number
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        //After picking winner ->restart raffle, reset the array, stamp the startign time
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(recentWinner);

        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) revert Raffle__transferFailed();
    }

    /* Getter Functions */
    function getEntranceFee() external view returns (uint256) {
        return i_entraceFee;
    }
}
