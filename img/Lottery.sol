//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract Lottery is Ownable, VRFConsumerBaseV2, ConfirmedOwner {
    // Enumerable de Estados de la Loteri
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    address payable[] public players;
    uint public usdEnterFee;
    AggregatorV3Interface internal ethUsdPriceFeed;
    LOTTERY_STATE public lottery_state;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    constructor(address _priceFeedAddress, address _vrfCoordinator) public VRFConsumerBaseV2(_vrfCoordinator) {
        usdEnterFee = 50 * (10 ** 18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        // $50
        //
        require(
            lottery_state == LOTTERY_STATE.OPEN,
            "La loteria no esta abierta"
        );
        require(msg.value >= getEntranceFee(), "No es suficiente ETH");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        (, int price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustPrice = uint256(price) * 10 ** 10;
        // $50, $2000 / ETH
        uint256 costToEnter = (usdEnterFee * 10 ** 18) / adjustPrice;

        return costToEnter;
    }

    // Agregar modificador de solo propietario
    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "La loteria ya esta abierta"
        );

        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        //Pseudo-aleotoriedad
        /* uint256(
            keccak256(
                abi.encodePacked(
                    nonce, // predecible
                    msg.sender,// predecible
                    block.difficulty, // manipulada por los mineros
                    block.timestamp // es predecible
                )
            )
        ) % players.length; */
    }
}
