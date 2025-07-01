# Motion Aware Event Representation-driven Image Deblurring-ECCV 2024🫶
This is the official code of Motion Aware Event Representation-driven Image Deblurring.
Training Code released!

## Motion Aware Event Representation-driven Image Deblurring(MAENet)
> Traditional image deblurring struggles with high-quality reconstruction due to limited motion data from single blurred images. Excitingly, the high-temporal resolution of event cameras records motion
more precisely in a different modality, transforming image deblurring.
However, many event camera-based methods, which only care about the
final value of the polarity accumulation, ignore the influence of the absolute intensity change where events generate so fall short in perceiving
motion patterns and effectively aiding image reconstruction. To overcome
this, in this work, we propose a new event preprocessing technique that
accumulates the deviation from the initial moment each time the event is
updated. This process can distinguish the order of events to improve the
perception of object motion patterns. To complement our proposed event
representation, we create a recurrent module designed to meticulously
extract motion features across local and global time scales. To further
facilitate the event feature and image feature integration, which assists in
image reconstruction, we develop a bi-directional feature alignment and
fusion module. This module works to lessen inter-modal inconsistencies.
Our approach has been thoroughly tested through rigorous experiments
carried out on several datasets with different distributions. These trials have delivered promising results, with our method achieving top-tier
performance in both quantitative and qualitative assessments.

## Overview

This is the overview of our network's architecture:
![image](https://github.com/ZhijingS/DA_event_deblur/blob/main/network.png)
The differences of our Deviation Accumulation(DA) event representation and other Polarity Accumulation(PA) representation:
![image](https://github.com/ZhijingS/DA_event_deblur/blob/main/DArep.png)
![image](https://github.com/ZhijingS/DA_event_deblur/blob/main/algo.png)
See more details in our paper.

## Installation
```
- pip install -r requirements.txt
```
## Dataset & Data Preprocess

- Please download the raw GoPro event dataset released by EFNet and follow the [README](https://github.com/ZhijingS/DA_event_deblur/blob/main/scripts/data_preparation/README.md) to create the DA event representation.

## Evaluation
The quantitative results of our method on GoPro, HS-ERGB and REBlur test datasets.
![image](https://github.com/ZhijingS/DA_event_deblur/blob/main/expres.png)
#### Pretrained Model Download 

The pretrained model on GoPro dataset: [Download](https://pan.baidu.com/s/1HiS0Bo03gu06FAvnLEgd8w?pwd=xeuh) (code:xeuh)  
The pretrained model on HS-ERGB dataset: [Download](https://pan.baidu.com/s/1LC6JhjK1dGkjpHgO-_1VOQ?pwd=yktx) (code:yktx)  
The pretrained model on REBlur dataset: [Download](https://pan.baidu.com/s/1etPnbp2DhgQW9lmWZKKkMQ?pwd=uy1s) (code:uy1s)  

#### Test
GoPro:
```
- python basicsr/test.py -opt options/test/GoPro/test_MAENet_GoPro.yml
```
HS-ERGB:
```
- python basicsr/test.py -opt options/test/HS_ERGB/test_MAENet_ERGB.yml
```
REBlur:
```
- python basicsr/test.py -opt options/test/GoPro/test_MAENet_REBlur.yml
```
## Training
GoPro:
```
- python basicsr/train.py -opt options/train/GoPro/MAENet_GoPro.yml
```
HS-ERGB:
```
- python basicsr/train.py -opt options/train/HS_ERGB/MAENet_ERGB.yml
```
REBlur:
```
- python basicsr/train.py -opt options/train/GoPro/MAENet_REBlur.yml
```
## Citation

If you find our work useful in your research, please consider citing:

```
@InProceedings{Sun_2024_ECCV,
    author    = {Sun, Zhijing and Fu, Xueyang and Huang, Longzhuo and Liu, Aiping and Zha, Zheng-Jun},
    title     = {Motion Aware Event Representation-driven Image Deblurring},
    booktitle = {Proceedings of the European conference on computer vision (ECCV)},
    year      = {2024},
    organization = {Springer}
}
```

## Contact

Should you have any question, please contact [sunzhijing@mail.ustc.edu.cn](sunzhijing@mail.ustc.edu.cn)

**Acknowledgment:** This code is based on the [BasicSR](https://github.com/xinntao/BasicSR) toolbox.

