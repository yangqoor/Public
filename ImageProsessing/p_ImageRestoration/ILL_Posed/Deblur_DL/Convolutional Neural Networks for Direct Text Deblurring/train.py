import matplotlib.pyplot as plt
import numpy as np
import os
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, datasets, models
from collections import defaultdict
from torch.nn.functional import mse_loss
import torch
import torch.nn as nn
import torch.optim as optim
from torch.optim import lr_scheduler
import time
import copy
import h5py
import cv2
import re
import L15


class SimDataset(Dataset):
    def __init__(self, train=True, dataset_size=None):
        self.directory_orig = 'D:\\Work\\Image Processing Project\\data\\data'
        # self.directory_blur = 'D:\\Work\\Image Processing Project\\data\\data'
        self.input_images = []
        self.target_masks = []

        if dataset_size is not None:
            count = 0

        paths = os.listdir(self.directory_orig)

        for filename in range(len(paths)):
            if train == True and filename % 5 != 0:
                if paths[filename].endswith("_blur.png"):
                    self.input_images.append(self.directory_orig + "\\{}".format(paths[filename]))
                    count += 1
                else:
                    continue
                if count == dataset_size:
                    break
            elif train == False and filename % 5 == 0:
                if paths[filename].endswith("_blur.png"):
                    self.input_images.append(self.directory_orig + "\\{}".format(paths[filename]))
                    count += 1
                else:
                    continue
                if count == dataset_size:
                    break
            else:
                continue
        self.target_masks = [words.replace('blur', 'orig') for words in self.input_images]

    def __len__(self):
        return len(self.input_images)

    def __getitem__(self, idx):
        image = self.input_images[idx]
        mask = self.target_masks[idx]

        # x = np.zeros((3,300, 300))
        # x[0,:image.shape[0], :image.shape[1]] = image

        # m=np.zeros((2,224,224))
        """k=to_categorical(mask,2)
        print(np.rollaxis(k,-1).shape)"""
        # m[:,:mask.shape[0], :mask.shape[1]] = np.rollaxis(to_categorical(mask,2),-1)
        image = re.sub(r"\\", r"\\\\", image)
        mask = re.sub(r"\\", r"\\\\", mask)
        image = torch.Tensor(cv2.cvtColor(cv2.imread(image), cv2.COLOR_BGR2RGB))
        mask = torch.Tensor(cv2.cvtColor(cv2.imread(mask), cv2.COLOR_BGR2RGB))
        random_number = np.random.randint(0, 235)
        image = image[random_number:random_number + 64, random_number:random_number + 64] / 255.0
        mask = mask[random_number:random_number + 64, random_number:random_number + 64] / 255.0
        return [image.permute(2, 0, 1), mask.permute(2, 0, 1)]

def calc_loss(pred, target, metrics, bce_weight=0.5):

    mse = criterion(pred, target)

    metrics['mse'] += torch.tensor(mse)  # * target.size(0)
    return mse


def print_metrics(metrics, epoch_samples, phase):
    outputs = []
    for k in metrics.keys():
        outputs.append("{}: {:4f}".format(k, metrics[k] / epoch_samples))

    if phase == "train":
        trains_loss.append(outputs)
    else:
        validation_loss.append(outputs)
    print("{}: {}".format(phase, ", ".join(outputs)))


def train_model(model, optimizer, scheduler, num_epochs=100):
    best_model_wts = copy.deepcopy(model.state_dict())
    best_loss = 1e10

    for epoch in range(num_epochs):
        print('Epoch {}/{}'.format(epoch, num_epochs - 1))
        print('-' * 10)
        since = time.time()
        # Each epoch has a training and validation phase
        for phase in ['train', 'val']:
            if phase == 'train':
                scheduler.step()
                for param_group in optimizer.param_groups:
                    print("LR", param_group['lr'])

                model.train()  # Set model to training mode
            else:
                model.eval()  # Set model to evaluate mode
            metrics = defaultdict(float)
            metrics['mse'] = 0
            epoch_samples = 0
            for inputs, labels in dataloaders[phase]:
                inputs = inputs.to(device)
                labels = labels.to(device)
                # zero the parameter gradients
                optimizer.zero_grad()
                # forward
                # track history if only in train
                with torch.set_grad_enabled(phase == 'train'):
                    outputs = model(inputs)
                    loss = calc_loss(outputs, labels, metrics)
                    # backward + optimize only if in training phase
                    if phase == 'train':
                        loss.backward()
                        optimizer.step()
                # statistics
                epoch_samples += inputs.size(0)
            print_metrics(metrics, epoch_samples, phase)

            count = 0

            for inputs, labels in dataloaders['val']:
                inputs = inputs.to(device)
                labels = labels.to(device)

                pred = 255.0 * np.array(model(inputs).permute(0, 2, 3, 1).to("cpu").detach())
                inputs = 255.0 * np.array(inputs.permute(0, 2, 3, 1).to("cpu").detach())
                labels = 255.0 * np.array(labels.permute(0, 2, 3, 1).to("cpu").detach())

                pred = np.hstack(pred)
                inputs = np.hstack(inputs)
                labels = np.hstack(labels)

                cv2.imwrite("pred_{}.jpg".format(epoch), pred)
                cv2.imwrite("labels_{}.jpg".format(epoch), labels)
                cv2.imwrite("inputs_{}.jpg".format(epoch), inputs)

                count += 1

                if count == 1:
                    break

            epoch_loss = metrics['loss'] / epoch_samples
            # deep copy the model
            if phase == 'val' and epoch_loss < best_loss:
                print("saving best model")
                best_loss = epoch_loss
                best_model_wts = copy.deepcopy(model.state_dict())
        time_elapsed = time.time() - since
        print('{:.0f}m {:.0f}s'.format(time_elapsed // 60, time_elapsed % 60))
    print('Best val loss: {:4f}'.format(best_loss))
    # load best model weights
    model.load_state_dict(best_model_wts)
    return model



if __name__ == '__main__':
    model = "L15"
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    num_epochs = 20

    train_set = SimDataset(True, dataset_size = 50000)
    valid_set = SimDataset(True, dataset_size = 500)
    batch_size = 16
    dataloaders = {'train': DataLoader(train_set, batch_size=batch_size, shuffle=True, num_workers=0), 'val': DataLoader(valid_set, batch_size=batch_size, shuffle=True, num_workers=0)}
    print(len(train_set))
    print(len(valid_set))

    inputs, masks = next(iter(DataLoader(train_set, batch_size=batch_size, shuffle=True, num_workers=0)))
    print(inputs.shape, masks.shape)
    model = L15.L15()
    model = model.to(device)


    validation_loss = []
    trains_loss = []
    criterion = nn.MSELoss()
    start = time.time()
    optimizer_ft = optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), lr=1e-4)
    exp_lr_scheduler = lr_scheduler.StepLR(optimizer_ft, step_size=30, gamma=0.1)
    model = train_model(model, optimizer_ft, exp_lr_scheduler, num_epochs=num_epochs)
    print(time.time() - start)
    torch.save(model.state_dict(), r"model.pth")