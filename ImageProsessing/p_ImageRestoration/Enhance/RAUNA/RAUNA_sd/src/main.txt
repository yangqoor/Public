import torch
import os
import utility
import data
import model
import model2
import loss
from option import args
from trainer import Trainer
from finetune import Finetune
import multiprocessing
import time


def print_network(net):
    num_params = 0
    for param in net.parameters():
        num_params += param.numel()
    print('Total number of parameters: %d' % num_params)

if __name__ == '__main__':
    torch.manual_seed(args.seed)
    checkpoint = utility.checkpoint(args)
    #os.environ["CUDA_VISIBLE_DEVICES"] = "0"
    print(args.finetune)
    if args.finetune==True:
        print('Begin Finetune!')
        model_de = model.Model(args, checkpoint)
        model_re = model2.Model(args, checkpoint)
        ft_loss = loss.Loss(args, checkpoint)
        ft_loader = data.Data(args)
        f = Finetune(args, model_de, model_re, ft_loss, ft_loader, checkpoint)
        while not f.terminate():
            f.finetune()
            f.validation()
        checkpoint.done()
    else:
        print('Begin Pre-Train!')
        if checkpoint.ok:
            loader = data.Data(args)
            model = model.Model(args, checkpoint)
            model2 = model2.Model(args, checkpoint)
            print_network(model)
            print_network(model2)
            loss = loss.Loss(args, checkpoint) if not args.test_only else None
            t = Trainer(args, loader, model, model2, loss, checkpoint)
            while not t.terminate():
                t.train()
                t.test()
            checkpoint.done()




    



