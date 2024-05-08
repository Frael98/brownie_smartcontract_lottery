from brownie import network, accounts, config, Contract, MockV3Aggregator, VRFCoordinatorMock, LinkToken 

DECIMALS = 8
STARTING_PRICE = 20000000000

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]

contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator,
    "vrf_coordinator": VRFCoordinatorMock,
    "token_link": LinkToken,
}


def get_account(id=None, index=None):
    """ Obterner el id de la cuenta a conectarse
    
        Id
        Index
    """
    if id:
        return accounts.load(id)
    if index:
        return accounts[index]

    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    # Devuelve la cuenta de metamask
    return accounts.add(config["wallets"]["from_key"])


def get_contract(contract_name):
    """ Tomar el address de contrato desde brownie config, si esta definido.
        Caso contrario, despliega Mocks de ese contrato

    Args:
        contract_name -> String
    Returns:
        brownie.network.contract.ProjectContract: Implementacion mas reciente
    """
    # Obtenemos el tipo de contrato
    contract_type = contract_to_mock[contract_name]
    # Si nos encontramos en una red local o development
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        # Si el contrato no ha sido desplegado, desplegamos los mockcs
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]

    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(
            contract_type._name, contract_address, contract_type.abi
        )

    return contract


def deploy_mocks():
    """ 
        Desplega los mocks
    """
    account = get_account()
    MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": account})
    linkToken = LinkToken.deploy({ "from": account})
    VRFCoordinatorMock.deploy(linkToken.address, { "from": account})
    print("Mocks desplegados")

def fund_with_link(contract_address, account=None, link_token=None, amount=100000000000000000):
    """ Funcion que fondea el contrato(Lottery_V1) con Tokens Link pora poder usar el servicio de VRF """
    """ contract_address: Direccion del contrato
        account: cuenta que fondea al contrato
        link_token: contrato del Link Token
        amount: cantidad de tokens """
    
    account = account if account else get_account()
    link_token = link_token if link_token else get_contract("token_link")
    # Transferimos la cantidad de tokens al contrato
    transaccion = link_token.transfer(contract_address, amount, {"from": account})
    transaccion.wait(1)
    
    print("El contrato ha sido fondeado")
    
    return transaccion
    