# -*- coding: gbk -*-
import os
import glob
import cv2, math
import numpy as np
from PIL import Image
import random
import numpy as np
import h5py
import os
from PIL import Image
import scipy.io
 
IMG_EXTENSIONS = [
    '.jpg', '.JPG', '.jpeg', '.JPEG',
    '.png', '.PNG', '.ppm', '.PPM', '.bmp', '.BMP',
]
#图片转矩阵
def pil_to_np(img_PIL):
    '''Converts image in PIL format to np.array.
    From W x H x C [0...255] to C x W x H [0..1]
    '''
    ar = np.array(img_PIL)
 
    if len(ar.shape) == 3:
        ar = ar.transpose(2, 0, 1)
    else:
        ar = ar[None, ...]
 
    return ar.astype(np.float32) / 255.
 
#矩阵转图片
def np_to_pil(img_np):
    '''Converts image in np.array format to PIL image.
    From C x W x H [0..1] to  W x H x C [0...255]
    '''
    ar = np.clip(img_np * 255, 0, 255).astype(np.uint8)
 
    if img_np.shape[0] == 1:
        ar = ar[0]
    else:
        ar = ar.transpose(1, 2, 0)
 
    return Image.fromarray(ar)
 
# 判断文件夹中是否有以上类型图片，没有则返回0
def is_image_file(filename):
    #如果不都为空、0、false，则any()返回true
    return any(filename.endswith(extension) for extension in IMG_EXTENSIONS)
 
#返回文件夹内文件绝对路径组成的列表
def make_dataset(dir):
    images = []
    assert os.path.isdir(dir), '%s is not a valid directory' % dir
 
    # os.walk(top[, topdown=True[, onerror=None[, followlinks=False]]]) 通过在目录树中游走输出在目录中的文件名，top返回三项（root,dirs,files），分别代表：
    # 当前正在遍历的这个文件夹的本身的地址；  list类型，内容是该文件夹中所有的目录的名字(不包括子目录)；  list类型，内容是该文件夹中所有的文件(不包括子目录)
    for root, _, fnames in sorted(os.walk(dir)):
        for fname in fnames:
                #print(fname)
                #拼接出图片的地址，并加入到images列表
                path = os.path.join(root, fname)
                images.append(path)
    return images
 
def hazy_simu(img_name,depth_or_trans_name,save_dir,pert_perlin = 0,airlight=0.76,is_imdepth=1,visual_range = [0.05, 0.1, 0.2, 0.5, 1]):
    """
    This is the function for haze simulation with the parameters given by
    the paper:
    HAZERD: an outdoor scene dataset and benchmark for single image dehazing
    IEEE Internation Conference on Image Processing, Sep 2017
    The paper and additional information on the project are available at:
    https://labsites.rochester.edu/gsharma/research/computer-vision/hazerd/
    If you use this code, please cite our paper.
    IMPORTANT NOTE: The code uses the convention that pixel locations with a
    depth value of 0 correspond to objects that are very far and for the
    simulation of haze these are placed a distance of 2 times the visual
    range.
    Authors:
    Yanfu Zhang: yzh185@ur.rochester.edu
    Li Ding: l.ding@rochester.edu
    Gaurav Sharma: gaurav.sharma@rochester.edu
    Last update: May 2017
    python version update : Aug 2021
    Authors :
    Haoying Sun : 1913434222@qq.com
    parse inputs and set default values
    Set default parameter values. Some of these are used only if they are not
    passed in
    :param img_name: the directory and name of a haze-free RGB image, the name
                     should be in the format of ..._RGB.jpg
    :param depth_name: the corresponding directory and name of the depth map, in
                     .mat file, the name should be in the format of ..._depth.mat
    :param save_dir: the directory to save the simulated images
    :param pert_perlin: 1 for adding perlin noise, default 0
    :param airlight:  3*1 matrix in the range [0,1]
    :param visual_range: a vector of any size
    :return: image name of hazy image
    """
    visual_range = [0.05, 0.1, 0.2, 0.5, 1]  #  visual range in km #可自行调整，或者使用range函数设置区间，此时需要修改beta_param,尚未研究
    beta_param = 3.912     #Default beta parameter corresponding to visual range of 1000m
    # A = np.zeros((1, 1, 3))
    # A[0, 0, 0] = airlight
    # A[0, 0, 1] = airlight
    # A[0, 0, 2] = airlight
    A = airlight
    if save_dir != '':
        if not os.path.exists(save_dir):
            os.makedirs(save_dir)
 
    print('Simulating hazy image for:{}'.format(img_name))
    VR = random.choice(visual_range)
    print('Viusal value: {} km'.format(VR) )
    im1 = cv2.imread(img_name)
    img_pil = pil_to_np(im1)
 
    #convert sRGB to linear RGB
    I = srgb2lrgb(img_pil)
    if is_imdepth:
        depths = get_depth(depth_or_trans_name)
        d = depths/1000   # convert meter to kilometer
 
        #Set regions where depth value is set to 0 to indicate no valid depth to
        #a distance of two times the visual range. These regions typically
        #correspond to sky areas
        d = np.where(d==0,2*VR,d)
        if pert_perlin:
            d = d * ((perlin_noise(np.zeros(d.shape)) - 0.5) + 1)
 
        #convert depth map to transmission
        beta = beta_param / VR
        beta = np.ones(d.shape) * beta
        transmission = np.exp((-beta*d))
        transmission_3 = np.array([transmission,transmission,transmission])
 
        #Obtain simulated linear RGB hazy image.Eq. 3 in the HazeRD paper
        Ic = transmission_3 * I+ (1 - transmission_3) * A
 
    else:
        Ic = pil_to_np(depth_or_trans_name) * I + (1 - pil_to_np(depth_or_trans_name)) * A
 
    # convert linear RGB to sRGB
    I2 = lrgb2srgb(Ic)
    haze_img = np_to_pil(I2)
 
    return haze_img
 
 
def perlin_noise(im, decay=2):
 
    """
    ——————————————————————————————————————————————————————————————————————————————
                        非均匀雾（柏林噪声）通常用柏林噪声来模拟大气湍流引起的非均匀雾，论文
    Towards Simulating Foggy and Hazy Images and Evaluating Their Authenticity
    生成三个不同频率参数(f=130、60、10）的三维柏林噪声，并通过以下方法组合:
    noise = 1/3 Sum_i(noise_i/2^(i-1)),i从1到3
    求得的noise与消光系数相乘，带入到Eq.2，模拟非均匀雾。
    I = Iex + Op*Ial    EQ.1
    Iex = Ipexp(-βex * rp)   EQ.2
    O = 1 - exp(-βex * rp)   EQ.3
    Iex：目标反射光经过大气中微粒衰减；Ial：环境光经过微粒散射，形成背景光； Op：模糊度；βex：消光系数
    ——————————————————————————————————————————————————————————————————————————————_
        This is the function for adding perlin noise to the depth map. It is a
    simplified implementation of the paper:
    an image sunthesizer
    Ken Perlin, SIGGRAPH, Jul. 1985
    The bicubic interpolation is used, compared to the original version.
    Reference:
    HAZERD: an outdoor scene dataset and benchmark for single image dehazing
    IEEE International Conference on Image Processing, Sep 2017
    The paper and additional information on the project are available at:
    https://labsites.rochester.edu/gsharma/research/computer-vision/hazerd/
    If you use this code, please cite our paper.
    Input:
      im: depth map
      varargin{1}: decay term
    Output:
      im: result of transmission with perlin noise added
    Authors:
      Yanfu Zhang: yzh185@ur.rochester.edu
      Li Ding: l.ding@rochester.edu
      Gaurav Sharma: gaurav.sharma@rochester.edu
    Last update: May 2017
    :return:
    """
    (h, w, c) = im.shape
    i = 1
    l_bound = min(h,w)
    while i <= l_bound:
        #d = imresize(randn(i, i)*decay, im.shape, 'bicubic')
        d = cv2.resize(np.random.randn(i,i)*decay, im.shape, interpolation=cv2.INTER_CUBIC)
        im = im+d
        i = i*2 
 
    im = (im - np.min(im)) / (np.max(im) - np.min(im))
    return im
 
def srgb2lrgb(I0):
    gamma = ((I0 + 0.055) / 1.055)**2.4
    scale = I0 / 12.92
    return np.where (I0 > 0.04045, gamma, scale)
 
def lrgb2srgb(I1):
    gamma =  1.055*I1**(1/2.4)-0.055
    scale = I1 * 12.92
    return np.where (I1 > 0.0031308, gamma, scale)
 
 
 
#获取深度矩阵
def get_depth(depth_or_trans_name):
    #depth_or_trans_name为mat类型文件或者img类型文件地址
    data = scipy.io.loadmat(depth_or_trans_name)
    depths = data['imDepth'] #深度变量
    #print(data.keys())  #打印mat文件中所有变量
    depths = np.array(depths)
    return depths
def AddHaze1(img):
    img = cv2.imread(img)
    img = np.array(img)
    img_f = img
    (row, col, chs) = img.shape
 
    A = 0.5  # 亮度
    beta = 0.08  # 雾的浓度
    size = math.sqrt(max(row, col))  # 雾化尺寸
    center = (row // 2, col // 2)  # 雾化中心
    for j in range(row):
        for l in range(col):
            d = -0.04 * math.sqrt((j - center[0]) ** 2 + (l - center[1]) ** 2) + size
            td = math.exp(-beta * d)
            img_f[j][l][:] = img_f[j][l][:] * td + A * (1 - td)
    return Image.fromarray(img_f.astype(np.uint8))
 
#请修改以下路径
img_dir = 'I:\HazeRD\data\img'
depth_dir = 'I:\HazeRD\data\depth'
save_dir = 'I:\HazeRD\data\depth\simu' #存放生成雾图结果
img_list = make_dataset(img_dir)
depth_list = make_dataset(depth_dir)
 
# # 生成雾图结果可视化
# a = hazy_simu(img_list[0],depth_list[0],save_dir)
# Image.Image.show(a)
# cv2.waitKey(1000)
 
# #原始图片可视化
# img_name= img_list[0]
# im1 = cv2.imread(img_name)
# im1 = Image.fromarray(im1.astype(np.uint8))
# Image.Image.show(im1)
# cv2.waitKey(1000)
 
# #深度图可视化
# depth_name = depth_list[0]
# depths = get_depth(depth_name)
# im1 = Image.fromarray(depths.astype(np.uint8))
# Image.Image.show(im1)
# cv2.waitKey(1000)