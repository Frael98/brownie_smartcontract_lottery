from brownie import config, accounts, network, Lottery_V1  # Lottery
from web3 import Web3

""" def test_get_entrance_fee():
    account = accounts[0]
    lottery_contract = Lottery.deploy(config['networks'][network.show_active()]['eth_usd_price_feed'] ,{"from": account})
    
    
    assert lottery_contract.getEntranceFee() > Web3.to_wei(0.010, 'ether') """
