from brownie import config, network, Lottery_V1, Contract
from web3 import Web3
from scripts.helpful import *
import time

def deploy():
    """ Desplega el Contrato Lottery_V1 """
    account = get_account()  # accounts[0]
    lottery_contract = Lottery_V1.deploy(
        get_contract("eth_usd_price_feed").address,
        get_contract("vrf_coordinator").address,
        get_contract("token_link").address,
        config['networks'][network.show_active()]['fee'],
        config['networks'][network.show_active()]['keyhash'],
        {"from": account}
    )

    print("Loteria desplegada")

def start_lottery():
    """ Funcion que empieza la Loteria """
    account = get_account()
    lottery = Lottery_V1[-1] # Solamente se ejecuta en tiempo de ejecucion
    starting_txn = lottery.startLottery({"from": account})
    starting_txn.wait(1)

def enter_lottery():
    """ Fuhncion para comenzar ingresar a la Loteria """
    account = get_account()
    lottery = Lottery_V1[-1]
    #Agregamos un poco mas al fee
    value = lottery.getEntranceFee() + 10000000
    tx = lottery.enter({"from": account, "value": value})
    tx.wait(1)
    print("Has entrado a la loteria!")
    

def end_lottery():
    account = get_account()
    lottery = Lottery_V1[-1]
    transacion = fund_with_link(lottery.address)
    transacion.wait(1)
    
    end_transaction = lottery.endLottery({"from": account})
    end_transaction.wait(1)
    # Esperamos 60 segundos pora la respuesta del nodo
    time.sleep(60)
    
    print(f"El nuevo ganador es {lottery.recentWinner()}")

def main():
    #print(network.show_active())
    #Desplegamos
    deploy()
    #Comenzamos
    start_lottery()
    #Entramos
    enter_lottery()
    #Terminamos
    end_lottery()
