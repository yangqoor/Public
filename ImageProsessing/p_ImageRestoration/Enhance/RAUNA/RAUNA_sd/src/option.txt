import argparse


parser = argparse.ArgumentParser(description='llenet')

parser.add_argument('--stage', type=int, default=10,
                    help='stage number S')
parser.add_argument('--num_L', type=int, default=32,
                    help='number of channels of L')
parser.add_argument('--num_R', type=int, default=32,
                    help='number of channels of R')
parser.add_argument('--lam', type=float, default = 6.0,   ###to be sure
                    help='the parameter of G')
parser.add_argument('--sigma', type=float, default=10,    ###to be sure
                    help='the parameter of G')
parser.add_argument('--eta2',type=float, default=3.0,     ###to be sure
                    help='the parameter of Rnet')
parser.add_argument('--gam', type=float, default=0,   ###to be sure
                    help='the parameter of Rnet')
parser.add_argument('--eta1', type=float, default=2.0,      ###to be sure
                    help='the parameter of Lnet')

parser.add_argument('--finetune_gamma', type=float, default=0.26,
                    help='the parameter of gamma correction')
#data
parser.add_argument('--dir_data', type=str, default='../data/',
                    help='dataset directory')


parser.add_argument('--data_train', type=str, default='our485',
                    help='train dataset name')
parser.add_argument('--data_test', type=str, default='eval15',
                    help='test dataset name')
parser.add_argument('--data_finetune', type=str, default='eval15_gamma',
                    help='finetune dataset name')
parser.add_argument('--data_validation', type=str, default='eval15_validation',
                    help='finetune validation dataset name')

parser.add_argument('--scale', type=str, default='1',
                    help='super resolution scale')   ###this could be useless
parser.add_argument('--epochs', type=int, default=100,
                    help='number of epochs to train')
parser.add_argument('--seed', type=int, default=1,
                    help='random seed')
parser.add_argument('--load', type=str, default='.',
                    help='file name to load')
parser.add_argument('--save', type=str, default='LLENet',
                    help='file name to save')
parser.add_argument('--reset', action='store_true',
                    help='reset the training')

parser.add_argument('--test_only', action='store_true',   #一旦有这个参数 默认为true 没有就是False
                    help='set this option to test the model')
parser.add_argument('--loss', type=str, default='1*MSE',
                    help='loss function configuration')
parser.add_argument('--ext', type=str, default='sep',
                    help='dataset file extension')
parser.add_argument('--cpu', action='store_true',
                    help='use cpu only')
parser.add_argument('--n_threads', type=int, default=0,
                    help='number of threads for data loading')
parser.add_argument('--self_ensemble', action='store_true',
                    help='use self-ensemble method for test')
parser.add_argument('--chop', action='store_true',
                    help='enable memory-efficient forward')
parser.add_argument('--precision', type=str, default='single',
                    choices=('single', 'half'),
                    help='FP precision for test (single | half)')
parser.add_argument('--n_GPUs', type=int, default=1,
                    help='number of GPUs')
parser.add_argument('--save_models', action='store_true',
                    help='save all intermediate models')
parser.add_argument('--model', default='LLENet',
                    help='model name')
parser.add_argument('--model2', default='renet',
                    help='model name')
parser.add_argument('--pre_train', type=str, default='.',
                    help='pre-trained model directory')
parser.add_argument('--pre_train_re', type=str, default='../experiment/LLENet/model2/model_best.pt',
                    help='pre-trained_re model checkpoint')
parser.add_argument('--pre_train_de', type=str, default='../experiment/LLENet/model/model_best.pt',
                    help='pre-trained_de model checkpoint')
parser.add_argument('--resume', type=int, default=0,
                    help='resume from specific checkpoint')
parser.add_argument('--optimizer', default='ADAM',
                    choices=('SGD', 'ADAM', 'RMSprop'),
                    help='optimizer to use (SGD | ADAM | RMSprop)')

parser.add_argument('--save_results', action='store_true',
                    help='save output results')

parser.add_argument('--beta1', type=float, default=0.9,
                    help='ADAM beta1')
parser.add_argument('--beta2', type=float, default=0.999,
                    help='ADAM beta2')
parser.add_argument('--lr', type=float, default=1e-5,
                    help='learning rate')
parser.add_argument('--lr_re', type=float, default=1e-4,
                    help='learning rate of reconstruction parts')
parser.add_argument('--lr_alpha', type=float, default=1e-2,
                    help='learning rate of finetune parts')
parser.add_argument('--lr_decay', type=int, default=5,
                    help='learning rate decay per N epochs')
parser.add_argument('--decay_type', type=str, default='step',
                    help='learning rate decay type')
parser.add_argument('--gamma', type=float, default=0.1,
                    help='learning rate decay factor for step decay')
parser.add_argument('--epsilon', type=float, default=1e-8,
                    help='ADAM epsilon for numerical stability')
parser.add_argument('--weight_decay', type=float, default=0,
                    help='weight decay')
parser.add_argument('--momentum', type=float, default=0.9,
                    help='SGD momentum')
parser.add_argument('--patch_size', type=int, default=64,
                    help='output patch size')
parser.add_argument('--test_every', type=int, default=2000,
                    help='do test per every N batches')
parser.add_argument('--batch_size', type=int, default=10,
                    help='input batch size for training')
parser.add_argument('--ft_batch', type=int, default=1,
                    help='input batch size for finetune')
parser.add_argument('--val_batch', type=int, default=1,
                    help='input batch size for finetune_validation')

parser.add_argument('--data_range', type=str, default='1-970/1-15',
                    help='train/test data range')
parser.add_argument('--no_augment', action='store_true',
                    help='do not use data augmentation')
parser.add_argument('--n_colors', type=int, default=3,
                    help='number of color channels to use')
parser.add_argument('--rgb_range', type=int, default=255,
                    help='maximum value of RGB')
parser.add_argument('--skip_threshold', type=float, default='1e8',
                    help='skipping batch that has large error')
parser.add_argument('--print_every', type=int, default=100,
                    help='how many batches to wait before logging training status')

parser.add_argument('--ratio', type=float, default=1.5,
                    help='the ratio of l_enhancement')
parser.add_argument('--conv_channels', type=int, default=64,
                    help='the num of conv_channels')
parser.add_argument('--eps', type=float, default=1e-3,
                    help='the parameter of G')

parser.add_argument('--gan_k', type=int, default=1,
                    help='k value for adversarial loss')
parser.add_argument('--alpha', type=float, default=0.85,
                    help='ratio of enhancement')
parser.add_argument('--adjust_brightness', type=float, default=4.8,
                    help='gamma of gamma_correction')
parser.add_argument('--ft_epochs', type=float, default=4,
                    help='epochs of test_finetune')
parser.add_argument('--finetune',dest='finetune',action='store_true',
                    help='do finetune not do train and test')
parser.add_argument('--no_finetune',dest='finetune',action='store_false',
                    help='do finetune not do train and test')
parser.add_argument('--save_dir',type=str,default='../results/0926/',
                    help='the direction of saving files')
parser.set_defaults(finetune=True)

args = parser.parse_args()

args.scale = list(map(lambda x: int(x), args.scale.split('+')))   ##this could be useless

if args.epochs == 0:
    args.epochs = 1e8

for arg in vars(args):
    if vars(args)[arg] == 'True':
        vars(args)[arg] = True
    elif vars(args)[arg] == 'False':
        vars(args)[arg] = False
