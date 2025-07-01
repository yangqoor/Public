# -*- coding: utf-8 -*-

import utils 

"""## Approximate Landweber"""

def aL(F, y, maxiter=500):
    L = y.copy()
    
    for i in range(maxiter):
        hp = y - F(L)
        hp = utils.reflect(hp)
        d = (F(L+hp) - F(L-hp))/2.0
        d = utils.reflect(d)
        L = L + d
    
    return L

