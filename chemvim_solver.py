import numpy as np

class ReactorConfig():
    def __init__(self):
        self.reactor = None
        self.num_reactors = None

class Reaction():
    def __init__(self):

        self.rctr_vol = None #L
        self.mol_flow_rate_A = None #mol/L
        self.conversion = None
        self.reaction_rate = None #mol/h 
        self.time = None #s

def CSTR(F_A0, X, r_A="undf"):
    if r_A != "undf":
        r_A = solve_r_A()
    V = (F_A0 * X) / - (r_A)

    return V
def solve_X(n, tau, k):
    if n == 1:
        X = (tau * k) / (1 + tau * k)
    return X

def solve_r_A(n,k, C_A, C_B, C_C, K_C):
    #n = reaction order
    if n == 1:
        r_A = k * C_A
    elif n == 2:
        r_A = 2
    return
    
