import os
import sys
import time

import torch

from utils.pytools import copytree, Unbuffered


def log(args):
    ''' Folder settings when saving training results'''
    if not os.path.exists('result') and ~args.debug:
        os.makedirs('result')
    if not os.path.exists('result/' + args.info) and ~args.debug:
        os.mkdir('result/' + args.info)
    if not os.path.exists('result/' + args.info + '/img') and ~args.debug:
        os.mkdir('result/' + args.info + '/img')
    if not os.path.exists('result/' + args.info + '/scripts') and ~args.debug:
        os.mkdir('result/' + args.info + '/scripts')
    if not os.path.exists('result/' + args.info + '/ckp') and ~args.debug:
        os.mkdir('result/' + args.info + '/ckp')



    print('[*] Info:', time.ctime())
    print('[*] Info:', os.path.basename(__file__))

    # if ~args.debug and args.log == True and args.resume == False:
    if ~args.debug and args.resume == False:
        from shutil import copyfile
        copyfile(os.path.basename(__file__), 'result/' + args.info + '/scripts/' + os.path.basename(__file__))
        copyfile('config.py', 'result/' + args.info + '/scripts/config.py')
        copyfile('head.py', 'result/' + args.info + '/scripts/head.py')
        copyfile('train.py', 'result/' + args.info + '/scripts/train.py')
        copyfile('test.py', 'result/' + args.info + '/scripts/test.py')
        copytree('./data_loader/', 'result/' + args.info + '/scripts/data_loader')
        copytree('./model/', 'result/' + args.info + '/scripts/model')
        copytree('./utils/', 'result/' + args.info + '/scripts/utils')


    sys.stdout = Unbuffered(sys.stdout)
    torch.cuda.set_device(args.gpu_idx)

    from torch import multiprocessing
    multiprocessing.set_sharing_strategy('file_system')
    torch.set_num_threads(1)


