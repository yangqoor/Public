# A deeplearning network based on Richardson-Lucy formula (Richardson-Lucy network, RLN)
This is a well-written RLN package for Incorporating the image formation process into deep learning improves network performance in deconvolution applications.
Now only for single view!
RLN is the companion code to our paper:

[Incorporating the image formation process into deep learning improves network performance in deconvolution applications](https://www.nature.com/articles/s41592-022-01652-7).

RLN is a 3D fully convolutional deep learning incorporating the Richardson-Lucy deconvolution formula to restore and enhance the resolution of fluorescence microscopy image.

## System Requirements

- Ubuntu 16.04.
- Python 3.6+
- NVIDIA GPU
- CUDA 10.1.243 and cuDNN 7.6.4
- Tensorflow 1.14.0

Tested Environment:

single-view RLN (for single GPU with 24 GB):
    - RLN model (./Test_model_based_on_data)
    - Ubuntu 16.04
    - Python 3.6
    - NVIDIA TITAN RTX 24GB
    - CUDA 10.0 and cuDNN 7.6.4
    - Tensorflow 1.14.0
    
## Dependencies Installation
If using conda, conda install tifffile -c conda-forge.
Otherwise, pip install tifffile.
RLN itself does not require installation, please just download the code and only takes few seconds on a typical PC.
Maybe you need to install numpy, tifffile, tqdm and other package.

## Parameter
You need to set some parameters with argparse:

    '--mode',  type=str, default='TS',  help="set the mode"
    '--batchsizes',  type=int, default=1,  help="set the batchsize number"
    '--gpu_id', type=str, default='0',   help="id(s) for CUDA_VISIBLE_DEVICES"
    '--gpu_memory_limit', type=float, default=0.4, help="limit GPU memory to this fraction (0...1)"
    '--train_iter', type=int, default=10000, help="set the training iteration number"
    '--crop_size', type=int, default=300, help="set the large data crop size"
    '--data_gen', type=bool, default=False, help="crop the train data or not"

    '--main_dir', type=str, default=None, help="path to folder with input images"
    '--normal_pmin', type=float, default=0.2, help="'pmin' for PercentileNormalizer"
    '--normal_pmax', type=float, default=99.8, help="'pmax' for PercentileNormalizer"

## training example
Before you train a RLN model, we reconmmend you to create the folders as follow:

    Main_folder (rename as you like):
      -- train
            --input
            --ground truth
      -- test
            --input
            --(ground truth) for validation

            
Then you can go to RLN-package folder and run:
python models_module.py --mode 'TR' --main_dir Main_folder --batchsizes N (N is the batchsize you used)

## Test and validate
For validating, you can run:
python models_module.py --mode 'VL' --main_dir Main_folder

For testing, you can run:
python models_module.py --mode 'TS' --main_dir Main_folder

For testing large data with crop and stitch, you can run:
python models_module.py --mode 'TSS' --main_dir Main_folder --crop_size KK (KK is the crop size for each volume, decided by the GPU limitation) 

