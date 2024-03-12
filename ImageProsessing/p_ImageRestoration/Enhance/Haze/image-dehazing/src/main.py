"""
Fast Single Image Haze Removal Using Dark Channel Prior
Final Project of "INF01050 - Computational Photography" class, 2016, at UFRGS.

Carlo S. Sartori
"""

import argparse;
import sys;
from AImage import AImage;
from Dehaze import dehaze;
import numpy;


#Prepare the arguments the program shall receive
def __prepareargs__():
    parser = argparse.ArgumentParser(description='Fast Single Image Haze Removal Using Dark Channel Prior.')
    parser.add_argument('-i', nargs=1, type=str, help='input image path', required=True)
    parser.add_argument('-o', nargs=1, type=str, help='output image path', required=True)
    parser.add_argument('-a', nargs=1, type=str, help='atm. light file path (default=None)', required=False)
    parser.add_argument('-t', nargs=1, type=str, help='transmission file path (default=None)', required=False)
    parser.add_argument('-rt', nargs=1, type=str, help='raw transmission file path (default=None)', required=False)
    parser.add_argument('-tmin', nargs=1, type=float, help='minimum transmission allowed (default=0.1)', required=False)
    parser.add_argument('-ps', nargs=1, type=int, help='patch size (default=15)', required=False)
    parser.add_argument('-w', nargs=1, type=float, help='omega weight (default=0.95)', required=False)
    parser.add_argument('-px', nargs=1, type=float, help='percentage of pixels for the atm. light (default=1e-3)', required=False)
    parser.add_argument('-r', nargs=1, type=int, help='pixel radius of guided filter (default=40)', required=False)
    parser.add_argument('-eps', nargs=1, type=float, help='epsilon of guided filter(default=1e-3)', required=False)
    parser.add_argument('-m', action='store_const', help='print out messages along processing', const=True, default=False, required=False)
    
    return parser

#Parse the input arguments and returns a dictionary with them
def __getargs__(parser):
    args = vars(parser.parse_args())
    return args


#The main module, in case this program was called as the main program
if __name__ == '__main__':
    #receive and prepare the arguments
    parser = __prepareargs__()
    args = __getargs__(parser)
    
    #get required parameters
    input_img_file = args['i'][0]
    output_img_file = args['o'][0]
    
    #default values of optional parameters
    a = None
    t = None
    rt = None
    tmin=0.1 
    ps=15 
    w=0.95 
    px=1e-3 
    r=40 
    eps=1e-3
    m = args['m']
    
    #check for optional parameters
    if args['a'] != None:
        a = numpy.loadtxt(args['a'][0])
    if args['t'] != None:
        t = numpy.loadtxt(args['t'][0])
    if args['rt'] != None:
        rt = numpy.loadtxt(args['rt'][0])
    if args['tmin'] != None:
        tmin = args['tmin'][0]
    if args['ps'] != None:
        ps = args['ps'][0]
    if args['w'] != None:
        w = args['w'][0]
    if args['px'] != None:
        px = args['px'][0]
    if args['r'] != None:
        r = args['r'][0]
    if args['eps'] != None:
        eps = args['eps'][0]
   

    #tries to open the input image
    try:
        img = AImage.open(input_img_file)
        if(m == True):
            print 'Image \''+input_img_file+'\' opened.'
    except IOError:
        print 'File \''+input_img_file+'\' cannot be found.'
        sys.exit()

    #Dehaze the input image    
    oimg = dehaze(img.array(), a, t, rt, tmin, ps, w, px, r, eps, m)
    
    #save the image to file
    simg = AImage.save(oimg, output_img_file)
    if(m == True):
        print 'Image \''+output_img_file+'\' saved.'
    
    print 'Dehazing finished!'
