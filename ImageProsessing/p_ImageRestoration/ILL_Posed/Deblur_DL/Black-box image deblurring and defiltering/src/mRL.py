# -*- coding: utf-8 -*-

import numpy as np
import utils


"""## Modified Richardson-Lucy"""

def mRL(F, y, maxiter=500):
    RL = y.copy()

    for i in range(maxiter):
        r1 = F(RL)/(np.abs(y)+1e-16)
        r1 = utils.reflect(r1)
        r2 = F(r1)
        r2 = utils.reflect(r2)
        RL = RL / (np.abs(r2)+1e-16)

        r1 = y / (np.abs(F(RL))+1e-16)
        r1 = utils.reflect(r1)
        r2 = F(r1)
        r2 = utils.reflect(r2)
        RL = RL * r2

    return RL

