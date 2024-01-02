#5#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import faulthandler
faulthandler.enable()
import os
os.environ['TF_CPP_MIN_LOG_LEVEL']='2'
import argparse



def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--mode',  type=str, default='TS',  help="set the mode")

    return parser, parser.parse_args()


if __name__=="__main__":
    parser, args = parse_args()
    mode=args.mode
    print(mode)

    path_in="C:/Users/tingwang/Desktop/"
    if "/" in path_in:
        path_in=os.sep.join(path_in.split("/"))

    if "//" in path_in:
        path_in=os.sep.join(path_in.split("//"))

    path_out=os.path.join(path_in,'output')
    os.rename(path_out, os.path.join(path_in,'output1'))
