import sys
from brownie import *
import brownie
import hashlib
import numpy as np

def createNonce(s):
    n = hashlib.sha256()
    n.update(s)
    return n.digest()

def doCommit(n,v):
    c = hashlib.sha256()
    c.update(n)
    c.update(v)
    return c.digest()

def main(number: int):
    user = ''

    v = b'\x02' if number % 2 == 0 else b'\x03'
    print(f'Value:  0x{v.hex()}')
    nonce1 = createNonce(b'nonce1')
    print(f'Nonce:  0x{nonce1.hex()}')
    commit1 = doCommit(nonce1,v)
    print(f"Commit: 0x{commit1.hex()}")

if __name__ == '__main__':
    main(int(sys.argv[1]))
