
## Pre-reqs


### Install external loss lib
```
git clone https://github.com/shubhtuls/PerceptualSimilarity.git
```

### CUB Data
1. Download CUB-200-2011 images somewhere:
```
cd misc &&  wget http://www.vision.caltech.edu/visipedia-data/CUB-200-2011/CUB_200_2011.tgz && tar -xf CUB_200_2011.tgz
```

2. Download CUB annotation mat files and pre-computed SfM outputs.
This should be saved in `misc/cachedir` directory:

```Bash
wget https://sfo2.digitaloceanspaces.com/yun/misc/cachedir.tar.gz && tar -vzxf cachedir.tar.gz
```
#### Computing SfM
**You may skip this**

We provide the computed SfM. If you want to compute them yourself, run via matlab:
```Bash
cd preprocess/cub
main
```


### Model training
you need to start `visdom.server` before training
```Bash
nohup python -m visdom.server & # remove nohup and `&` to see error
```

Change the `name` to whatever you want to call. Also see `main.py` to adjust
hyper-parameters (for eg. increase `tex_loss_wt` and `text_dt_loss_wt` if you
want better texture, increase texture resolution with `tex_size`).
See `nnutils/mesh_net.py` and `nnutils/train_utils.py` for more model/training options.


```Bash
python  main.py --name=bird_net --display_port 8097
```


More settings:
```Bash
# Stronger texture & higher resolution texture.
python main.py --name=bird_net_better_texture --tex_size=6 --tex_loss_wt 1. --tex_dt_loss_wt 1. --display_port 8088

# Stronger texture & higher resolution texture + higher res mesh. 
python main.py --name=bird_net_hd --tex_size=6 --tex_loss_wt 1. --tex_dt_loss_wt 1. --subdivide 4 --display_port 8089
```


### Evaluation
We provide evaluation code to compute the IOU curves in the paper.
Command below runs the model with different ablation settings.
Run it from one directory above the `cmr` directory.
```Bash
python misc/benchmark/run_evals.py --split val  --name bird_net --num_train_epoch 500
```

Then, run 
```Bash
python misc/benchmark/plot_curvess.py --split val  --name bird_net --num_train_epoch 500
```
in order to see the IOU curve.
