# -*- coding: utf-8 -*-
"""
Created on Mon May  6 12:23:13 2019

plane wave class where a plane wave 
(electromagnetic wave) is rendered in 3D space

Editor:
    Shihao Ran
    STIM Laboratory
"""

#%%
# import packages
import numpy as np

#%%
class planewave():
    #implement all features of a plane wave
    #   k, E, frequency (or wavelength in a vacuum)--l
    #   try to enforce that E and k have to be orthogonal
    
    #initialization function that sets these parameters when a plane wave is created
    def __init__ (self, k, E):
        
        #self.phi = phi
        self.k = k/np.linalg.norm(k)                      
        self.E = E
        
        #force E and k to be orthogonal
        if ( np.linalg.norm(k) > 1e-15 and np.linalg.norm(E) >1e-15):
            s = np.cross(k, E)              #compute an orthogonal side vector
            s = s / np.linalg.norm(s)       #normalize it
            Edir = np.cross(s, k)              #compute new E vector which is orthogonal
            self.k = k
            self.E = Edir / np.linalg.norm(Edir) * np.linalg.norm(E)
    
    def get_k_E(self, k, E):
        self.k = k/np.linalg.norm(k)    
        self.E = E
    
    def __str__(self):
        return str(self.k) + "\n" + str(self.E)     #for verify field vectors use print command

    #function that renders the plane wave given a set of coordinates
    def evaluate(self, X, Y, Z):
        k_dot_r = self.k[0] * X + self.k[1] * Y + self.k[2] * Z     #phase term k*r
        ex = np.exp(1j * k_dot_r)       #E field equation  = E0 * exp (i * (k * r)) here we simply set amplitude as 1
        Ef = self.E.reshape((3, 1, 1)) * ex
        return Ef