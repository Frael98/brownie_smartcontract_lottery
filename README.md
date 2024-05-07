1. Los usuarios podran entrar en la loteria usando ETH cuyo precio estara basado en USD -> 50 $
2. Un admin va a decidir cuando la loteria se termina
3. La loteria va seleccionar un ganador de manera aleatoria


## Aleatoriedad Protocolo VRF
![alt text](img/VRF%20Chainlink.png)

### Uso del servicio GetRandomNumber - en remix (example)

- Ir a `https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number`

- Crearse una suscripcion en VRF Chanilink `https://vrf.chain.link/sepolia/`

- Una vez creada y fondeada con TOKEN, desplegar el contrato con el id de la suscripcion.

![alt text](img/Suscripcion%20VRF.png)

- Una vez desplegado el contrato, realizar la peticion de `requestRandomWords` - Obtener el id de la peticion`lastRequestId` - Consultar el estado o valor con el id en `getRequestStatus`

![alt text](img/Despliegue%20de%20Contrato%20VRF%20Consumer.png)


## brownie-config.yaml
Archivo de configuracion del proyecto, dependencias, compilador, remapeos, redes