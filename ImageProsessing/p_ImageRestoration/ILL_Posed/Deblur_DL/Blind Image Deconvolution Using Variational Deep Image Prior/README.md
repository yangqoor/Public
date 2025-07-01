# Blind Image Deconvolution Using Variational Deep Image Prior
Offical implementation of [Blind Image Deconvolution Using Variational Deep Image Prior](https://arxiv.org/abs/2202.00179)

Dong Huo, Abbas Masoumzadeh, Rafsanjany Kushol, and Yee-Hong Yang

## Overview

Conventional deconvolution methods utilize hand-crafted image priors to constrain the optimization. While deep-learning-based methods have simplified the optimization by end-to-end training, they fail to generalize well to blurs unseen in the training dataset. Thus, training image-specific models is important for higher generalization. Deep image prior (DIP) provides an approach to optimize the weights of a randomly initialized network with a single degraded image by maximum a posteriori (MAP), which shows that the architecture of a network can serve as the hand-crafted image prior. Different from the conventional hand-crafted image priors that are statistically obtained, it is hard to find a proper network architecture because the relationship between images and their corresponding network architectures is unclear. As a result, the network architecture cannot provide enough constraint for the latent sharp image. This paper proposes a new variational deep image prior (VDIP) for blind image deconvolution, which exploits additive hand-crafted image priors on latent sharp images and approximates a distribution for each pixel to avoid suboptimal solutions. Our mathematical analysis shows that the proposed method can better constrain the optimization. The experimental results further demonstrate that the generated images have better quality than that of the original DIP on benchmark datasets.

## Prerequisites
- Python 3.8 
- PyTorch 1.9.0
- Requirements: opencv-python
- Platforms: Ubuntu 20.04, RTX A6000, cuda-11.1

## Datasets
VDIP is evaluated on synthetic and real blurred datasets [Lai et al](http://vllab.ucmerced.edu/wlai24/cvpr16_deblur_study/).

## Citation

If you use this code for your research, please cite our paper.

```

@article{huo2023blind,
  title={Blind Image Deconvolution Using Variational Deep Image Prior},
  author={Huo, Dong and Masoumzadeh, Abbas and Kushol, Rafsanjany and Yang, Yee-Hong},
  journal={IEEE Transactions on Pattern Analysis and Machine Intelligence},
  year={2023},
  publisher={IEEE}
}

```
