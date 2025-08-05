#!/usr/bin/python3
from pwn import *
import warnings
import os
warnings.filterwarnings('ignore')
context.arch = 'amd64'
context.terminal = ['tmux','splitw','-h']

fname = './' # Add binary

LOCAL = True # Change this to False for remote connection

os.system('clear')

# For remote, run: python solver.py <IP> <PORT>  #
# e.g. python solver.py 127.0.0.1 1337           #

# ============================================== #

if LOCAL:
  print('Running solver locally..\n')
  r    = process(fname)
else:
  IP   = str(sys.argv[1]) if len(sys.argv) >= 2 else '0.0.0.0'
  PORT = int(sys.argv[2]) if len(sys.argv) >= 3 else 1337
  r    = remote(IP, PORT)
  print(f'Running solver remotely at {IP} {PORT}\n')

# ============================================== #

e    = ELF(fname, checksec=False)
libc = ELF(e.runpath.decode() + 'libc.so.6', checksec=False)
rop  = ROP(e)

# Helper functions #
# ============================================== # 

rl  = lambda     : r.recvline()
ru  = lambda x   : r.recvuntil(x)
sa  = lambda x,y : r.sendafter(x,y)
sla = lambda x,y : r.sendlineafter(x,y)

# ============================================== #