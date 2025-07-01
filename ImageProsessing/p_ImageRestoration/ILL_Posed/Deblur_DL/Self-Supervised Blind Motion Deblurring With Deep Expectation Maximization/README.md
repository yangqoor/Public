# Deblur_MCEM
The repo provides the demo code for the nonuniform deblurring method. For more efficient Langevin sampling, we provide the preconditioned gradient descent Langevin (p-LD) iteration, which is used in the demo code.

## Requirement

All the codes are tested on Ubuntu LTS 18.04. Pls ensure the working OS system matches the required OS version.

## Request the demo python file

The following two demo files are accessible upon the request at [matliji@163.com](mailto:matliji@163.com).

```bash
Lai_nonuniform_cvpr_MCEM_pLD.py
Gopro_nonuniform_cvpr_MCEM_pLD.py
```
## Reconstruction of Lai nonuniform dataset

You can access the forward_operator demo file and the reconstruction of the Lai nonuniform dataset at [Google driver](https://drive.google.com/drive/folders/1iIxe6OObfSiGhwDMfCTpCYoZJGBkmOos?usp=sharing). The quantitative metric is also provided, where the rotation is taken into consideration.

## Run the demo

### For the Lai nonuniform dataset
    ```bash
    python3 Lai_nonuniform_cvpr_MCEM_pLD.py
    ```

### For the Gopro nonuniform deblurring
    ```bash
    python3 Gopro_nonuniform_cvpr_MCEM_pLD.py
    ```



## Citation

If you find our work useful in your research or publication, please cite it:

```
@inproceedings{li2023self,
  title={Self-Supervised Blind Motion Deblurring With Deep Expectation Maximization},
  author={Li, Ji and Wang, Weixi and Nan, Yuesong and Ji, Hui},
  booktitle={Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition},
  pages={13986--13996},
  year={2023}
}
```