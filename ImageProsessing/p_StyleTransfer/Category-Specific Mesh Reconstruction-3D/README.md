# TL;DR

This repo migrate the following work to Python3 and latest PyTorch [v1.3]:

1. [Learning Category-Specific Mesh Reconstruction from Image Collections (ECCV 2018)](https://github.com/akanazawa/cmr)
2. [Neural 3D Mesh Renderer (CVPR 2018)](https://github.com/hiroharu-kato/neural_renderer)

Special thanks to the them and [neural_renderer_pytorch](https://github.com/daniilidis-group/neural_renderer).


What's new here:
- update the code [Python2 -> Python3, PyTorch 0.x -> PyTorch 1.3].
- Remove Chainer/Cupy dependancy (Chainer is depreciated and it's painful to install cupy).
- Simplify the environment setup.
- Slightly reorg and simplify the code.


![Neural Render](https://raw.githubusercontent.com/hiroharu-kato/neural_renderer/master/examples/data/example1.gif)


![CMR](https://akanazawa.github.io/cmr/resources/images/teaser.png)

### Requirements
- Python 3 [Python2 may work as well]
- [PyTorch](https://pytorch.org/) tested on version `1.3.0`

### Installation


#### Setup python
```
conda create -n cmr python=3
conda activate cmr
conda install pytorch torchvision -c pytorch
pip install -r requirements.txt
```


#### install neural_renderer
```
export CUDA_HOME=/path/to/cuda/ 
```

Install [CUDA here](https://developer.nvidia.com/cuda-toolkit-archive)  with the same version as PyTorch `python -c 'import torch;print(torch.version.cuda)'`. You may skip it if you alreadly have it in your machine.  


Make sure you set the right `CUDA_HOME` (e.g. `ls $CUDA_HOME/bin/nvcc` works.)
and then build extension
```
python setup.py install # install to sys.path
python setup.py build develop # install to workspace
```

 
### Demo
1. From the `cmr` directory, download the trained model:
```
cd misc && wget https://people.eecs.berkeley.edu/~kanazawa/cachedir/cmr/model.tar.gz && tar -vzxf model.tar.gz && cd ..
```
You should see `misc/cachedir/snapshots/bird_net/`

2. Run the demo:
```
python demo.py --name bird_net --num_train_epoch 500 --img_path misc/demo_data/img1.jpg
python demo.py --name bird_net --num_train_epoch 500 --img_path misc/demo_data/birdie.jpg
```

### Training
Please see [train.md](train.md)

### Citation
If you use this code for your research, please consider citing:
```
@inProceedings{cmrKanazawa18,
  title={Learning Category-Specific Mesh Reconstruction
  from Image Collections},
  author = {Angjoo Kanazawa and
  Shubham Tulsiani
  and Alexei A. Efros
  and Jitendra Malik},
  booktitle={ECCV},
  year={2018}
}
@InProceedings{kato2018renderer
    title={Neural 3D Mesh Renderer},
    author={Kato, Hiroharu and Ushiku, Yoshitaka and Harada, Tatsuya},
    booktitle={The IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
    year={2018}
}
```
