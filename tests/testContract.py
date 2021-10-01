#!/usr/bin/python3
import brownie
import hashlib
import json
import uuid
from brownie import *


def createNonce(s):
    n = hashlib.sha256()
    n.update(s)
    return n.digest()


def doCommit(nonce: bytes, value: bytes):
    c = hashlib.sha256()
    c.update(nonce)
    c.update(value)
    return c.digest()


def generateValue(value: bytes):
    nonce = createNonce(str(uuid.uuid4()).encode('utf-8'))
    return nonce, doCommit(nonce, value)


# Par sempre é o dono
# Ímpar é sempre o jogador
def main():
    user1, user2 = accounts[0], accounts[1]

    v1, v2 = b'\x03', b'\x05'  # 8 => par => dono deve ganhar
    nonce1, commit1 = generateValue(v1)
    nonce2, commit2 = generateValue(v2)

    print(f'Value:  0x{v1.hex()}')
    print(f'Nonce:  0x{nonce1.hex()}')
    print(f"Commit: 0x{commit1.hex()}")
    print('-' * 30)
    print(f'Value:  0x{v2.hex()}')
    print(f'Nonce:  0x{nonce2.hex()}')
    print(f"Commit: 0x{commit2.hex()}")

    SimpleCommit.deploy({'from': user1})
    evenOddContract = EvenOdd.deploy(commit1, {'from': user1, 'amount': 1000})

    evenOddContract.joinGame(commit2, {'from': user2, 'amount': 500})

    evenOddContract.ownerReveal(nonce1, v1, {'from': user1})
    evenOddContract.guestReveal(nonce2, v2, {'from': user2})

    winnerMsg: TransactionReceipt  = evenOddContract.payWinner({'from': user1})
    print(json.dumps(winnerMsg))
