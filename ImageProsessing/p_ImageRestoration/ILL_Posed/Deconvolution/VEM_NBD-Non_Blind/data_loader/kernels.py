import numpy as np
from utils.imtools import cconv_np, edgetaper, pad_for_kernel
def get_blur(image, std, ker, seed = False, tapper = False, conv_mode = 'wrap'):

    if seed != False:
        np.random.seed(seed)

    if isinstance(std, list):
        std_upp = std[1]
        std_low = std[0]
        std = np.random.uniform(std_low, std_upp)

    # Produce Training Data with tapper.
    if tapper:
        bl_no = cconv_np(image,ker,mode='valid')
        shape = np.shape(bl_no)
        noise = std/255*np.random.randn(*shape)
        bl = bl_no + noise
        bl = edgetaper(pad_for_kernel(bl, ker, 'edge'), ker)
        bl = bl.astype(np.float32)
        return bl

    # Produce Training Data w/o tapper.
    bl_no = cconv_np(image, ker, conv_mode)
    shape = np.shape(bl_no)
    noise = std/255*np.random.randn(*shape)
    bl = bl_no + noise
    bl = bl.astype(np.float32)

    return bl
