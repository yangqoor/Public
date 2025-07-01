import torch
import os
import random
import sys
sys.path.append('/home-nfs/gilton/learned_iterative_solvers')
import torch.nn as nn
import torch.optim as optim
from torchvision import transforms

import operators.blurs as blurs
from operators.operator import OperatorPlusNoise
from utils.celeba_dataloader import CelebaTrainingDatasetSubset, CelebaTestDataset
from networks.u_net import UnetModel
from solvers.neumann import PrecondNeumannNet
from testing import standard_testing

# Parameters to modify
n_epochs = 80
current_epoch = 0
batch_size = 8
n_channels = 3
learning_rate = 0.001
print_every_n_steps = 10
save_every_n_epochs = 5
initial_eta = 0.1

initial_data_points = 10000
# point this towards your celeba files
data_location = "/share/data/vision-greg2/mixpatch/img_align_celeba/"

kernel_size = 5

# modify this for your machine
save_location = "/share/data/vision-greg2/users/gilton/gaussianblur_nonoise_precondneumann.ckpt"

gpu_ids = []
for ii in range(6):
    try:
        torch.cuda.get_device_properties(ii)
        print(str(ii), flush=True)
        if not gpu_ids:
            gpu_ids = [ii]
        else:
            gpu_ids.append(ii)
    except AssertionError:
        print('Not ' + str(ii) + "!", flush=True)

print(os.getenv('CUDA_VISIBLE_DEVICES'), flush=True)
gpu_ids = [int(x) for x in gpu_ids]
# device management
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
use_dataparallel = len(gpu_ids) > 1
print("GPU IDs: " + str([int(x) for x in gpu_ids]), flush=True)

# Set up data and dataloaders
transform = transforms.Compose(
    [
        transforms.Resize((128, 128)),
        transforms.ToTensor(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
    ]
)

test_dataset = CelebaTestDataset(data_location, transform=transform)
test_dataloader = torch.utils.data.DataLoader(
    dataset=test_dataset, batch_size=batch_size, shuffle=False, drop_last=True,
)

### Set up solver and problem setting

forward_operator = blurs.GaussianBlur(sigma=5.0, kernel_size=kernel_size,
                                      n_channels=3, n_spatial_dimensions=2).to(device=device)
measurement_process = forward_operator

internal_forward_operator = blurs.GaussianBlur(sigma=5.0, kernel_size=kernel_size,
                                      n_channels=3, n_spatial_dimensions=2).to(device=device)

# standard u-net
learned_component = UnetModel(in_chans=n_channels, out_chans=n_channels, num_pool_layers=4,
                                       drop_prob=0.0, chans=32)
solver = PrecondNeumannNet(linear_operator=internal_forward_operator, nonlinear_operator=learned_component,
                    lambda_initial_val=initial_eta, cg_iterations=6)

if use_dataparallel:
    solver = nn.DataParallel(solver, device_ids=gpu_ids)
solver = solver.to(device=device)

start_epoch = 0
cpu_only = not torch.cuda.is_available()


if os.path.exists(save_location):
    if not cpu_only:
        saved_dict = torch.load(save_location)
    else:
        saved_dict = torch.load(save_location, map_location='cpu')
    solver.load_state_dict(saved_dict['solver_state_dict'])
else:
    print("JUST SO YOU KNOW, YOUR CHECKPOINT DOES NOT EXIST. CONTINUING WITH A RANDOMLY-INITIALIZED SOLVER.")


# set up loss and train
lossfunction = torch.nn.MSELoss()

# Do train
standard_testing.test_solver(solver=solver, test_dataloader=test_dataloader,
                               measurement_process=measurement_process, device=device)