import argparse
import time
import copy
import tqdm
import os
import re

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision
from torchvision import transforms
from torch.optim import Adam
import warnings
warnings.filterwarnings('ignore')

from utils.models import Meta, VGG16, TransformerNet
from utils.util import normalize_batch, tv_loss, load_image, save_image

def main():
    main_arg_parser = argparse.ArgumentParser(description="parser for Meta Networks for Neural Style Transfer")
    subparsers = main_arg_parser.add_subparsers(title="subcommands", dest="subcommand")

    train_arg_parser = subparsers.add_parser("train", help="parser for training arguments")
    train_arg_parser.add_argument("--epochs", type=int, default=60,
                                  help="number of training epochs, default is 60")
    train_arg_parser.add_argument("--batch_size", type=int, default=8,
                                  help="batch size for training, default is 8 (applies only to the content images)")
    train_arg_parser.add_argument("--content_dataset", type=str, default= './content/',
                                  help="path to content images dataset, the path should point to a folder "
                                       "containing another folder with all the training content images")
    train_arg_parser.add_argument("--style_dataset", type=str, default = './style/',
                                  help="path to style images dataset, the path should point to a folder "
                                       "containing another folder with all the training style images")
    train_arg_parser.add_argument("--save_model_dir", type=str, default= './models/',
                                   help="path to folder where trained model will be saved, default is ./models/")
    train_arg_parser.add_argument("--checkpoint_model_dir", type=str, default='./checkpoints/',
                                  help="path to folder where checkpoints of trained models will be saved, default is ./checkpoints/")
    train_arg_parser.add_argument("--image_size", type=int, default=256,
                                  help="size of training images, default is 256 X 256")
    train_arg_parser.add_argument("--cuda", type=int, default = 1,
                                  help="set it to 1 for running on GPU, 0 for CPU, default is 1")
    train_arg_parser.add_argument("--content_weight", type=float, default=1,
                                  help="weight for content-loss, default is 1")
    train_arg_parser.add_argument("--style_weight", type=float, default=250,
                                  help="weight for style-loss, default is 250")
    train_arg_parser.add_argument("--tv_weight", type=float, default=1e-4,
                                  help="weight for total-varition-loss, default is 1e-4")                                  
    train_arg_parser.add_argument("--lr", type=float, default=1e-3,
                                  help="learning rate, default is 1e-3")
    train_arg_parser.add_argument("--log_interval", type=int, default=100,
                                  help="number of images after which the training loss is logged, default is 100")
    train_arg_parser.add_argument("--checkpoint_interval", type=int, default=1000,
                                  help="number of batches after which a checkpoint of the trained model will be created, default is 1000")

    eval_arg_parser = subparsers.add_parser("eval", help="parser for evaluation/stylizing arguments")
    eval_arg_parser.add_argument("--content_image", type=str, required=True,
                                 help="path to content image you want to stylize")
    eval_arg_parser.add_argument("--content_size", type=float, default=256,
                                 help="factor for scaling down the content image")
    eval_arg_parser.add_argument("--output-image", type=str, required=True,
                                 help="path for saving the output image")
    eval_arg_parser.add_argument("--model", type=str, required=True,
                                  help="saved model to be used for stylizing the image")
    eval_arg_parser.add_argument("--cuda", type=int, default=1,
                                 help="set it to 1 for running on GPU, 0 for CPU, default is 1")

    args = main_arg_parser.parse_args()
    
    if args.subcommand is None:
        print("ERROR: specify either train or eval")
        sys.exit(1)
    if args.cuda and not torch.cuda.is_available():
        print("ERROR: cuda is not available, try running on CPU")
        sys.exit(1)

    if args.subcommand == "train":
        check_paths(args)
        train(args)
    else:
        stylize(args)

def train(args):
    device = torch.device("cuda:0" if args.cuda else 'cpu')
    epochs = args.epochs
    content_weight = args.content_weight  
    style_weight = args.style_weight
    
    transform = transforms.Compose([
        transforms.Resize(args.image_size),
        transforms.CenterCrop(args.image_size),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                            std=[0.229, 0.224, 0.225])])

    style_dataset = torchvision.datasets.ImageFolder(root = args.style_dataset, transform = transform)
    style_loader = torch.utils.data.DataLoader(style_dataset, batch_size = 1, shuffle = True)
    content_dataset = torchvision.datasets.ImageFolder(root = args.content_dataset, transform = transform)
    content_loader = torch.utils.data.DataLoader(content_dataset, batch_size = args.batch_size)

    vgg = VGG16(requires_grad= False).to(device) # Pretrained VGG-16 network
    tfm = TransformerNet().to(device) # Transformer Network
    meta = Meta().to(device) # Meta Network
    
    params = list(tfm.parameters()) + list(meta.parameters())
    optimizer = Adam(params, lr= 1e-3)
    mse_loss = torch.nn.MSELoss()

    if os.path.isfile(os.path.join(args.checkpoint_model_dir, 'checkpoint.pth.tar')):
        
        checkpoint = torch.load(os.path.join(args.checkpoint_model_dir, 'checkpoint.pth.tar'))
        start_epoch = checkpoint['epoch']
        start_batch = checkpoint['batch']
        tfm.load_state_dict(checkpoint['tfm_state_dict'])
        meta.load_state_dict(checkpoint['meta_state_dict'])
        optimizer.load_state_dict(checkpoint['optimizer'])

        print("=> loaded checkpoint '{}' (epoch {} batch {})"
                        .format(os.path.join(args.checkpoint_model_dir, 'checkpoint.pth.tar'), checkpoint['epoch'], checkpoint['batch']))
    else:
        print("=> no checkpoint found at '{}'".format(os.path.join(args.checkpoint_model_dir, 'checkpoint.pth.tar')))
        start_epoch = 0
        start_batch = 0

    for e in range(start_epoch, args.epochs):
        style_iter = iter(style_loader)
        style, _ = next(style_iter)

        for batch_id, (content, _) in tqdm.tqdm(enumerate(content_loader)):

            if batch_id < start_batch:
                continue
            start_batch = 0
            content = content.to(device)
            
            if batch_id % 20 == 0:
                try:
                    style, _ = next(style_iter)
                except StopIteration:
                    style_iter = iter(style_loader)
                    style, _ = next(style_iter)
                except (IOError, OSError, Image.DecompressionBombError):
                    style, _ = next(style_iter)
            style = style.to(device)

            # Getting the features
            target_style_features = vgg(style)
            target_content_features = vgg(content)
            vgg_out = vgg(style)
            weights = meta(vgg_out)
            transferred = tfm(content, weights)
            transferred_features = vgg(normalize_batch(transferred))
            
            # Computing the losses
            content_loss = mse_loss(target_content_features.relu3_3, transferred_features.relu3_3)
            style_loss = 0
            for i in range(len(transferred_features)):
                transferred_mean_std = torch.cat(torch.std_mean(transferred_features[i], dim = (2,3)), dim = 1)
                target_style_mean_std = torch.cat(torch.std_mean(target_style_features[i], dim = (2,3)), dim = 1)
                style_loss += mse_loss(transferred_mean_std, target_style_mean_std)
            tvar_loss = tv_loss(transferred, args.tv_weight)
            loss = (args.content_weight * content_loss) + (args.style_weight * style_loss) + tvar_loss

            loss.backward()
            optimizer.step()

            # Logging the losses
            if (batch_id + 1) % args.log_interval == 0:
                mesg = "{}\tEpoch {}:\t[{}/{}]\tcontent: {:.6f}\tstyle: {:.6f}\t ttv: {:.6f}\t total: {:.6f}".format(
                    time.ctime(), e + 1, 8 * (batch_id + 1), len(content_dataset),
                                content_loss.item(),
                                style_loss.item(),
                                tvar_loss.item(),
                                content_loss.item() + style_loss.item() + tvar_loss.item()                                
                )
                print(mesg)

            # Checkpointing models
            if args.checkpoint_model_dir is not None and (batch_id + 1) % args.checkpoint_interval == 0:
                tfm.eval().cpu()
                meta.eval().cpu()
                ckpt_model_path = os.path.join(args.checkpoint_model_dir, 'checkpoint.pth.tar')
                torch.save({'epoch': e, 'batch' : batch_id + 1, 'tfm_state_dict': tfm.state_dict(),
                            'meta_state_dict': meta.state_dict(), 'optimizer' : optimizer.state_dict()}, ckpt_model_path)

                tfm.to(device).train()
                meta.to(device).train()
    # save model
    if args.save_model_dir is not None:
        tfm.eval().cpu()
        meta.eval().cpu()
        save_model_filename = "epoch_" + str(args.epochs) + "_" + str(
            args.content_weight) + "_" + str(args.style_weight) + ".model"
        save_model_path = os.path.join(args.save_model_dir, save_model_filename)
        torch.save({'tfm_state_dict': tfm.state_dict(), 'meta_state_dict': meta.state_dict()}, save_model_path)

        print("\nDone, trained model saved at", save_model_path)
    
def stylize(args):
    device = torch.device("cuda" if args.cuda else "cpu")
    content_image = load_image(args.content_image, size=args.content_size)
    content_transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Lambda(lambda x: x.mul(255))
    ])
    content_image = content_transform(content_image)
    content_image = content_image.unsqueeze(0).to(device)

    with torch.no_grad():
        style_model = TransformerNet()
        model = torch.load(args.model)
        state_dict = model['tfm_state_dict']   
        for k in list(state_dict.keys()):
            if re.search(r'in\d+\.running_(mean|var)$', k):
                del state_dict[k]
        style_model.load_state_dict(checkpoint['tfm_state_dict'])
        style_model.to(device)
        output = style_model.forward(content_image, weights = None).cpu()

    save_image(args.output_image, output[0])

def check_paths(args):

    try:
        if args.save_model_dir is not None and not os.path.exists(args.save_model_dir):
            os.makedirs(args.save_model_dir)
        if args.checkpoint_model_dir is not None and not (os.path.exists(args.checkpoint_model_dir)):
            os.makedirs(args.checkpoint_model_dir)
    except OSError as e:
        print(e)
        sys.exit(1)

if __name__ == "__main__":
    main()
