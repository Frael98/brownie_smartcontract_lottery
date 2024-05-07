//SPDX-License-Identifier: MIT
/** 
 IMPORTANTE: Este contrato usa la version 1 de Chainlink VRF, siendo esta version deprecada y sin soporte, 
 por lo que las redes que la soportan ya son pocas, por tal motivo, no es posible desplegar el contrato en la red 
 de sepolia testnet u otras que no sean las que estan en la pagina ofical de Chainlink VRF v1: https://docs.chain.link/vrf/v1/supported-networks
 Pero si es posible desplegar el contrato con Mocks en una red local solamente.
**/
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//import {VRFConsumerBase} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol"; -> Para version de compilador 0.8.0
import {VRFConsumerBase} from "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery_V1 is Ownable, VRFConsumerBase {
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

    // VRF variables
    // Llave
    bytes32 internal keyHash;
    // Valor a pagar
    uint256 internal fee;
    // Numero aleatorio
    uint256 public randomResult;
    //ganador reciente
    address payable public recentWinner;

    constructor(
        address _priceFeedAddress,
        address _vrfCoordinator,
        address _tokenLink,
        uint256 _fee,
        bytes32 _keyHash
    ) public VRFConsumerBase(_vrfCoordinator, _tokenLink) {
        usdEnterFee = 50 * (10 ** 18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        fee = _fee;
        keyHash = _keyHash;
    }

    /**
        Entra el usuario a la loteria
     */
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

        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        // Obtenemos el id de la peticion
        bytes32 requestId = requestRandomness(keyHash, fee);
    }

    // Sobreescribimos la funcion
    function fulfillRandomness(
        bytes32 _requestId,
        uint256 _randomness
    ) internal override {
        //randomResult = _randomness;
        //emit RequestFulfilled(_requestId, _randomness);
        require(_randomness > 0, "Random no encontrada");
        require(
            lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "Loteria no ha sido abierta"
        );
        //Modulo de randomness
        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];
        //Pagarle al jugador
        recentWinner.transfer(address(this).balance);
        // Reiniciar loteria
        players = new address payable[](0);

        lottery_state = LOTTERY_STATE.CLOSED;
        randomResult = _randomness;
    }
}
