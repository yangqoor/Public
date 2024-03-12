"""
Fast Single Image Haze Removal Using Dark Channel Prior
Final Project of "INF01050 - Computational Photography" class, 2016, at UFRGS.

Carlo S. Sartori
"""

import numpy;
from scipy import misc;

#A class to hold an Image
class AImage(object):
    """
    Class to hold an Image.
    """
    #img_array is the matrix of pixels in img
    __img_array__ = None;
    #filename is the path to the image in img
    __filename__ = None;
        
    def __init__(self, img=None, filename=None):
        self.__filename__ = filename
        self.__img_array__ = img
        
    def height(self):
        return self.__img_array__.shape[0]
    
    def width(self):
        return self.__img_array__.shape[1]
    
    def colors(self):
        return self.__img_array__.shape[2]
    
    def filename(self):
        return self.__filename__
        
    def __getitem__(self, index):
        return self.__img_array__[index]
    
    def __setitem__(self, index, value):
        self.__img_array__[index] = value
    
    def array(self):
        return self.__img_array__       
    
    def show(self):
        misc.imshow(self.__img_array__)  
    
    @staticmethod
    def fromarray(array):
        #check if the array is float type
        if array.dtype != numpy.float64:
            #cast to float with values from 0 to 1
            array = numpy.divide(numpy.asfarray(array), 255.0)
        
        simg = AImage(array)
        return simg
    
    @staticmethod
    def open(filename):
        try:
            array = misc.imread(filename)
            #check if the array is float type
            if array.dtype != numpy.float64:
                #cast to float with values from 0 to 1
                array = numpy.divide(numpy.asfarray(array), 255.0)
                
            img = AImage(array, filename) 
        except IOError:
            raise IOError
        
        return img
    
    @staticmethod
    def save(im, filename):
        if type(im) is AImage:
            misc.imsave(filename, im.array())
            simg = AImage(im.array(), filename)
        elif type(im) is numpy.ndarray:
            misc.imsave(filename, im)
            simg = AImage(im, filename)
        else:
            raise TypeError('im parameter should be either a numpy.ndarray or AImage.AImage')
                    
        return simg
    
