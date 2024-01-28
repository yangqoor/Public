''' kernel preparation and forward models '''
import numpy as np
from PIL import Image
from scipy.ndimage import filters
import torch
import torch.nn.functional as F
'''torch2np'''
def torch2np(x_tensor):
    if isinstance(x_tensor, np.ndarray):
        return x_tensor
    elif x_tensor.is_cuda == False:
        x = x_tensor.numpy()
        return x
    else:
        x = x_tensor.detach().cpu().numpy()
        return x

def np2torch(x, cuda=False):
    if isinstance(x, torch.Tensor):
        return x
    else:
        x = torch.from_numpy(x.copy())
        x = x.type(torch.float32)
        if cuda == True:
            x = x.cuda()
        return x



def for_fft(ker, shape):
    ker_mat = np.zeros(shape, dtype=np.float32)
    ker_shape = np.asarray(np.shape(ker))
    circ = np.ndarray.astype(-np.floor((ker_shape) / 2), dtype=np.int)
    ker_mat[:ker_shape[0], :ker_shape[1]] = ker
    ker_mat = np.roll(ker_mat, circ, axis=(0, 1))
    return ker_mat

def fspecial(type, *args):
    dtype = np.float32
    if type == 'average':
        siz = (args[0],args[0])
        h = np.ones(siz) / np.prod(siz)
        return h.astype(dtype)
    elif type == 'gaussian':
        p2 = args[0]
        p3 = args[1]
        siz = np.array([(p2[0]-1)/2 , (p2[1]-1)/2])
        std = p3
        x1 = np.arange(-siz[1], siz[1] + 1, 1)
        y1 = np.arange(-siz[0], siz[0] + 1, 1)
        x, y = np.meshgrid(x1, y1)
        arg = -(x*x + y*y) / (2*std*std)
        h = np.exp(arg)
        sumh = sum(map(sum, h))
        if sumh != 0:
            h = h/sumh
        return h.astype(dtype)
    elif type == 'motion':
        p2 = args[0]
        p3 = args[1]
        len = max(1, p2)
        half = (len - 1) / 2
        phi = np.mod(p3, 180) / 180 * np.pi

        cosphi = np.cos(phi)
        sinphi = np.sin(phi)
        xsign = np.sign(cosphi)
        linewdt = 1

        eps = np.finfo(float).eps
        sx = np.fix(half * cosphi + linewdt * xsign - len * eps)
        sy = np.fix(half * sinphi + linewdt - len * eps)

        x1 = np.arange(0, sx + 1, xsign)
        y1 = np.arange(0, sy + 1, 1)
        x, y = np.meshgrid(x1, y1)

        dist2line = (y * cosphi - x * sinphi)
        rad = np.sqrt(x * x + y * y)

        lastpix = np.logical_and(rad >= half, np.abs(dist2line) <= linewdt)
        lastpix.astype(int)
        x2lastpix = half * lastpix - np.abs((x * lastpix + dist2line * lastpix * sinphi) / cosphi)
        dist2line = dist2line * (-1 * lastpix + 1) + np.sqrt(dist2line ** 2 + x2lastpix ** 2) * lastpix
        dist2line = linewdt + eps - np.abs(dist2line)
        logic = dist2line < 0
        dist2line = dist2line * (-1 * logic + 1)

        h1 = np.rot90(dist2line, 2)
        h1s = np.shape(h1)
        h = np.zeros(shape=(h1s[0] * 2 - 1, h1s[1] * 2 - 1))
        h[0:h1s[0], 0:h1s[1]] = h1
        h[h1s[0] - 1:, h1s[1] - 1:] = dist2line
        h = h / sum(map(sum, h)) + eps * len * len

        if cosphi > 0:
            h = np.flipud(h)

        return h.astype(dtype)


'''convolution operator'''
def cconv_torch(x,ker):
    with torch.no_grad():
        x_h, x_v = x.size()
        conv_ker = np.flip(np.flip(ker, 0), 1)
        ker = torch.FloatTensor(conv_ker.copy()).cuda()
        k_h, k_v = ker.size()
        k2_h = k_h // 2
        k2_v = k_v // 2
        x = torch.cat((x[-k2_h:,:], x, x[0:k2_h,:]), dim = 0).cuda()
        x = torch.cat((x[:,-k2_v:], x, x[:,0:k2_v]), dim = 1).cuda()
        x = x.unsqueeze(0).cuda()
        x = x.unsqueeze(1).cuda()
        ker = ker.unsqueeze(0).cuda()
        ker = ker.unsqueeze(1).cuda()
        y1 = F.conv2d(x, ker).cuda()
        y1 = torch.squeeze(y1)
        y = y1[-x_h:, -x_v:]
    return y

def cconv_np(data, ker, mode='wrap'):
    # notice it might give false result when x is not the type.
    # Pay Attention, data and kernel is not interchangeable!!!
    if mode =='wrap':
        return filters.convolve(data, ker, mode='wrap')
    elif mode == 'valid':
        return fftconvolve(data, ker, mode='valid')


def conv_valid(x,ker):
    '''valid convolution'''
    with torch.no_grad():
        conv_ker = np.flip(np.flip(ker, 0), 1)
        ker = torch.FloatTensor(conv_ker.copy()).cuda()
        ker = ker.unsqueeze(0).cuda()
        ker = ker.unsqueeze(1).cuda()
        y1 = F.conv2d(x, ker).cuda()
    return y1

def deconv_valid(x,ker):
    '''inverse operator of valid convolution'''
    conv_ker = np.flip(np.flip(ker, 0), 1)
    ker = torch.FloatTensor(conv_ker.copy()).cuda()

    ker = ker.unsqueeze(0).cuda()
    ker = ker.unsqueeze(1).cuda()
    y1 = F.conv_transpose2d(x, ker).cuda()
    return y1

def imshow(x_in,str,dir = 'tmp/'):
    x = torch2np(x_in)
    x = np.squeeze(x)
    if len(x.shape) == 2:
        x[x > 1] = 1
        x[x < 0] = 0
        x_int = np.uint8(np.around(x * 255))
        Image.fromarray(x_int, 'L').save(dir + str + '.png')
    elif len(x.shape) == 3:
        x[x > 1] = 1
        x[x < 0] = 0
        x_int = np.uint8(np.around(x * 255))
        Image.fromarray(x_int,'RGB').save(dir + str + '.png')



from scipy.signal import fftconvolve
def pad_for_kernel(img, kernel, mode):
    hy = (kernel.shape[0] - 1) // 2
    hx = (kernel.shape[0] - 1) - hy
    wy = (kernel.shape[1] - 1) // 2
    wx = (kernel.shape[1] - 1) - wy
    # p = [(d - 1) // 2 for d in kernel.shape]
    padding = [[hx, hy], [wx, wy]]
    return np.pad(img, padding, mode)
def edgetaper(img, kernel, n_tapers=3):
    '''tap edges for immitation of circulant boundary. '''
    alpha = edgetaper_alpha(kernel, img.shape)
    _kernel = kernel
    for i in range(n_tapers):
        blurred = fftconvolve(pad_for_kernel(img, _kernel, 'wrap'), kernel, mode='valid')
        img = alpha * img + (1 - alpha) * blurred
    return img
def edgetaper_alpha(kernel,img_shape):
    v = []
    for i in range(2):
        z = np.fft.fft(np.sum(kernel,1-i),img_shape[i]-1)
        z = np.real(np.fft.ifft(np.square(np.abs(z)))).astype(np.float32)
        z = np.concatenate([z,z[0:1]],0)
        v.append(1 - z/np.max(z))
    return np.outer(*v)
def pad_for_ker_and_db(bl,ker,db = None):
    '''pad the kernel by edge tapper when db is None and pad by convolution with db. See FDN'''
    im_num = len(ker)
    bl_pad = torch.zeros_like(bl)
    for i in range(im_num):
        _bl = torch2np(bl[i:i+1,])
        if db is None:
            out = edgetaper(pad_for_kernel(_bl[0,0,:,:], ker[i], 'edge'), ker[i])
            bl_pad[i:i+1,] = np2torch(out, cuda=True).unsqueeze(0).unsqueeze(0)
        else:
            _db = torch2np(db[i:i+1,])
            hy = (ker[i].shape[0] - 1) // 2
            hx = (ker[i].shape[0] - 1) - hy
            wy = (ker[i].shape[1] - 1) // 2
            wx = (ker[i].shape[1] - 1) - wy
            out = cconv_np(_db[0,0,], ker[i])
            out[hx:-hy,wx:-wy] = _bl[0,0,hx:-hy,wx:-wy]
            bl_pad[i:i+1,] = np2torch(out, cuda=True).unsqueeze(0).unsqueeze(0)
    return bl_pad



'''optimizer'''
def cg_torch(A, B, X0 = None, n_loop = 50, tol = 1e-5, verbose=False):
    with torch.no_grad():
        X0 = X0
        if X0 is None:
            X0 = torch.zeros_like(B)
        r0 = A(X0) - B
        p = -r0
        X = X0
        # Iteration
        err0 = float("inf")
        for iter in range(n_loop):
            Ap = A(p)
            alpha = torch.dot(r0.view(-1), r0.view(-1)) / torch.dot(p.view(-1), Ap.view(-1))
            X = X + alpha * p
            r1 = r0 + alpha * Ap
            err1 = torch.norm(r1)
            if verbose == True:
                print('iter %d, err %2.2f' %(iter, err1.cpu().numpy()))

            beta = torch.dot(r1.view(-1), r1.view(-1)) / torch.dot(r0.view(-1), r0.view(-1))
            p = -r1 + beta * p
            r0 = r1
            if err1 < tol:
                return X
            if err1 > err0:
                pass
            else:
                err0 = err1

            if iter == n_loop-1:
                # print('[!] CG Method reaches its maximum loop!, The final step err is {}'.format(err1))
                return X
