import os, sys
import random
import argparse, yaml, logging, shutil
import torch
import torch.utils.data as data
import torchvision.transforms as transforms
import torchvision.utils as tvu
import torchvision
import numpy as np
from tqdm import tqdm
from PIL import Image
from functools import partial
from .unet import SuperResModel, UNetModel, EncoderUNetModel
from .models import Model


def parse_args_and_config(args):

    # parse config file
    with open(os.path.join("../configs", args.config), "r") as f:
        config = yaml.safe_load(f)
    new_config = dict2namespace(config)

    level = getattr(logging, args.verbose.upper(), None)
    if not isinstance(level, int):
        raise ValueError("level {} not supported".format(args.verbose))

    handler1 = logging.StreamHandler()
    formatter = logging.Formatter(
        "%(levelname)s - %(filename)s - %(asctime)s - %(message)s"
    )
    handler1.setFormatter(formatter)
    logger = logging.getLogger()
    logger.addHandler(handler1)
    logger.setLevel(level)

    # os.makedirs(os.path.join(args.exp, "image_samples"), exist_ok=True)
    # args.image_folder = os.path.join(
    #     args.exp, "image_samples", args.image_folder
    # )
    # if not os.path.exists(args.image_folder):
    #     os.makedirs(args.image_folder)
    # else:
    #     overwrite = False
    #     if args.ni:
    #         overwrite = True
    #     else:
    #         response = input(
    #             f"Image folder {args.image_folder} already exists. Overwrite? (Y/N)"
    #         )
    #         if response.upper() == "Y":
    #             overwrite = True

    #     if overwrite:
    #         shutil.rmtree(args.image_folder)
    #         os.makedirs(args.image_folder)
    #     else:
    #         print("Output image folder exists. Program halted.")
    #         sys.exit(0)

    # add device
    device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
    # logging.info("Using device: {}".format(device))
    new_config.device = device

    # set random seed
    torch.manual_seed(args.seed)
    np.random.seed(args.seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(args.seed)

    torch.backends.cudnn.benchmark = True

    return new_config


def dict2namespace(config):
    namespace = argparse.Namespace()
    for key, value in config.items():
        if isinstance(value, dict):
            new_value = dict2namespace(value)
        else:
            new_value = value
        setattr(namespace, key, new_value)
    return namespace


class Diffusion(object):
    def __init__(self, args, config, device=None):
        import pdb
        # pdb.set_trace()
        self.args = args
        self.config = config
        if device is None:
            device = (
                torch.device("cuda")
                if torch.cuda.is_available()
                else torch.device("cpu")
            )
        self.device = device

        self.model_var_type = config.model.var_type
        betas = get_beta_schedule(
            beta_schedule=config.diffusion.beta_schedule,
            beta_start=config.diffusion.beta_start,
            beta_end=config.diffusion.beta_end,
            num_diffusion_timesteps=config.diffusion.num_diffusion_timesteps,
        )
        betas = self.betas = torch.from_numpy(betas).float().to(self.device)
        self.num_timesteps = betas.shape[0]

        alphas = 1.0 - betas
        alphas_cumprod = alphas.cumprod(dim=0)
        alphas_cumprod_prev = torch.cat(
            [torch.ones(1).to(device), alphas_cumprod[:-1]], dim=0
        )
        self.alphas_cumprod_prev = alphas_cumprod_prev
        posterior_variance = (
            betas * (1.0 - alphas_cumprod_prev) / (1.0 - alphas_cumprod)
        )
        if self.model_var_type == "fixedlarge":
            self.logvar = betas.log()
        elif self.model_var_type == "fixedsmall":
            self.logvar = posterior_variance.clamp(min=1e-20).log()

    def sample(self, input_shape0):
        """执行DDNM+采样过程，支持简化版和SVD版两种模式"""
        cls_fn = None  # 初始化分类器梯度函数
        
        if self.config.model.type == 'openai':
            # 加载OpenAI扩散模型（如ImageNet预训练模型）
            config_dict = vars(self.config.model)
            model = create_model(**config_dict)  # 创建基础扩散模型
            
            # 加载无条件或有条件扩散模型检查点（对应论文2.1节DDPM结构）
            if self.config.model.class_cond:
                ckpt = os.path.join(self.args.exp, f'logs/imagenet/{self.config.data.image_size}x{self.config.data.image_size}_diffusion.pt')
            else:
                ckpt = os.path.join(self.args.exp, "logs/imagenet/256x256_diffusion_uncond.pt")
                # if not os.path.exists(ckpt):
                #     download('https://openaipublic.blob.core.windows.net/diffusion/jul-2021/256x256_diffusion_uncond.pt', ckpt)
            
            # 加载模型权重并部署到设备（论文4.1节实验细节）
            model.load_state_dict(torch.load(ckpt, map_location=self.device))
            model.to(self.device)
            model.eval()
            model = torch.nn.DataParallel(model)

            betas = self.betas


        # x = self.svd_based_ddnm_plus(model, cls_fn, input_shape0)  # 调用SVD版本（需奇异值分解）
        return model, betas  # 返回生成的噪声图像
            
        
    def svd_based_ddnm_plus(self, model, cls_fn, input_shape0):
        args, config = self.args, self.config

        dataset, test_dataset = get_dataset(args, config)

        device_count = torch.cuda.device_count()

        if args.subset_start >= 0 and args.subset_end > 0:
            assert args.subset_end > args.subset_start
            test_dataset = torch.utils.data.Subset(test_dataset, range(args.subset_start, args.subset_end))
        else:
            args.subset_start = 0
            args.subset_end = len(test_dataset)

        # print(f'Dataset has size {len(test_dataset)}')

        # def seed_worker(worker_id):
        #     worker_seed = args.seed % 2 ** 32
        #     np.random.seed(worker_seed)
        #     random.seed(worker_seed)

        g = torch.Generator()
        g.manual_seed(args.seed)
        # worker_init_fn = partial(seed_worker, seed=self.args.seed)

        args.sigma_y = 2 * args.sigma_y #to account for scaling to [-1,1]

        #Start DDIM
        x = torch.randn(
            input_shape0,
            config.data.channels,
            config.data.image_size,
            config.data.image_size,
            device=self.device,
        )

        with torch.no_grad():
            x = diffusion_prior(x, model, self.betas, config=config)

            # x = [inverse_data_transform(config, xi) for xi in x]
        return x


def get_beta_schedule(beta_schedule, *, beta_start, beta_end, num_diffusion_timesteps):
    def sigmoid(x):
        return 1 / (np.exp(-x) + 1)

    if beta_schedule == "quad":
        betas = (
            np.linspace(
                beta_start ** 0.5,
                beta_end ** 0.5,
                num_diffusion_timesteps,
                dtype=np.float64,
            )
            ** 2
        )
    elif beta_schedule == "linear":
        betas = np.linspace(
            beta_start, beta_end, num_diffusion_timesteps, dtype=np.float64
        )
    elif beta_schedule == "const":
        betas = beta_end * np.ones(num_diffusion_timesteps, dtype=np.float64)
    elif beta_schedule == "jsd":  
        betas = 1.0 / np.linspace(
            num_diffusion_timesteps, 1, num_diffusion_timesteps, dtype=np.float64
        )
    elif beta_schedule == "sigmoid":
        betas = np.linspace(-6, 6, num_diffusion_timesteps)
        betas = sigmoid(betas) * (beta_end - beta_start) + beta_start
    else:
        raise NotImplementedError(beta_schedule)
    assert betas.shape == (num_diffusion_timesteps,)
    return betas


def compute_alpha(beta, t):
    beta = torch.cat([torch.zeros(1).to(beta.device), beta], dim=0)
    a = (1 - beta).cumprod(dim=0).index_select(0, t + 1).view(-1, 1, 1, 1)
    return a


def diffusion_prior(x, model, b, config=None):
    """扩散过程
    
    Args:
        x: 初始噪声张量
        model: 预训练的去噪扩散模型
        b: 扩散步长参数
        eta: DDIM中的随机性控制参数(η)，影响生成多样性
        A_funcs: 包含线性算子A及其伪逆A_pinv的处理器
        y: 观测的退化图像
        cls_fn: 分类器梯度函数(可选，用于有条件生成)
        classes: 类别标签(可选)
        
    Returns:
        list: 恢复后的图像序列
        list: 预测的x0序列
    """
    # import pdb
    # pdb.set_trace()
    with torch.no_grad():  # 推理阶段不计算梯度
        # 初始化变量
        skip = config.diffusion.num_diffusion_timesteps // config.time_travel.T_sampling  # 时间步跳跃间隔
        n = x.size(0)  # Batch大小
        x0_preds = [] # 存储各时间步预测的x0
        xs = [x]  # 存储各时间步的噪声图像xt

        # 生成时间旅行计划表（对应论文Algo.2）
        times = get_schedule_jump(
            config.time_travel.T_sampling, 
            config.time_travel.travel_length, 
            config.time_travel.travel_repeat,
        )
        time_pairs = list(zip(times[:-1], times[1:]))  # 生成时间步对，如(t, t-1)
        
        # 反向扩散采样循环
        print(f"扩散采样循环 Sampling steps: {len(time_pairs)}")
        # for i, j in tqdm(time_pairs):
        for i, j in time_pairs:
            i, j = i * skip, j * skip  # 计算实际时间步（考虑跳跃）
            if j < 0: j = -1  # 处理边界条件

            if j < i:  # 正常反向扩散步骤（对应论文Algo.1）
                # --- 时间步计算 ---
                t = (torch.ones(n) * i).to(x.device)
                # next_t = (torch.ones(n) * j).to(x.device)
                at = compute_alpha(b, t.long())        # 计算α_t（式5）
                # at_next = compute_alpha(b, next_t.long())
                
                # --- 噪声预测 ---
                xt = xs[-1].to('cuda').float()  # 获取当前时间步的噪声图像

                et = model(xt, t)                  # 预测噪声ε_t（式7）
                
                # --- 估计x0与零空间修正 ---
                if et.size(1) == 6:  # 处理多通道输出
                    et = et[:, :3]
                x0_t = (xt - et * (1 - at).sqrt()) / at.sqrt()  # 估计x0|t（式12）
                
                # # 零空间修正：x0_t_hat = A†y + (I - A†A)x0|t（式13）
                # x0_t_hat = x0_t - A_funcs.A_pinv(
                #     A_funcs.A(x0_t.reshape(x0_t.size(0), -1)) - y.reshape(y.size(0), -1)
                # ).reshape(*x0_t.size())
                
                # # --- 生成下一时间步xt_next（式14）---
                # c1 = (1 - at_next).sqrt() * eta        # 控制随机性的系数
                # c2 = (1 - at_next).sqrt() * ((1 - eta**2)**0.5)
                # xt_next = at_next.sqrt() * x0_t_hat + c1 * torch.randn_like(x0_t) + c2 * et
                
                # # 保存结果
                x0_preds.append(x0_t)
                # xs.append(xt_next.to('cpu'))
                
            else:  # 时间旅行（对应论文3.3节Time-Travel Trick）
                # next_t = (torch.ones(n) * j).to(x.device)
                # at_next = compute_alpha(b, next_t.long())
                # x0_t = x0_preds[-1].to('cuda').float()  # 使用历史x0预测
                x0_t = x0_preds[-1]
                
                # # 重新添加噪声：xt_next ~ q(xt_next | x0_t)（式5）
                # xt_next = at_next.sqrt() * x0_t + torch.randn_like(x0_t) * (1 - at_next).sqrt()
                # xs.append(xt_next.to('cpu'))

    # return [xs[-1]], [x0_preds[-1]]  # 返回最终结果
    return x0_t.to('cuda'), x0_preds[-2].to('cuda')


# form RePaint
def get_schedule_jump(T_sampling, travel_length, travel_repeat):

    jumps = {}
    for j in range(0, T_sampling - travel_length, travel_length):
        jumps[j] = travel_repeat - 1

    t = T_sampling
    ts = []

    while t >= 1:
        t = t-1
        ts.append(t)

        if jumps.get(t, 0) > 0:
            jumps[t] = jumps[t] - 1
            for _ in range(travel_length):
                t = t + 1
                ts.append(t)

    ts.append(-1)

    _check_times(ts, -1, T_sampling)

    return ts


def _check_times(times, t_0, T_sampling):
    # Check end
    assert times[0] > times[1], (times[0], times[1])

    # Check beginning
    assert times[-1] == -1, times[-1]

    # Steplength = 1
    for t_last, t_cur in zip(times[:-1], times[1:]):
        assert abs(t_last - t_cur) == 1, (t_last, t_cur)

    # Value range
    for t in times:
        assert t >= t_0, (t, t_0)
        assert t <= T_sampling, (t, T_sampling)


NUM_CLASSES = 1000

def create_model(
    image_size,
    num_channels,
    num_res_blocks,
    channel_mult="",
    learn_sigma=False,
    class_cond=False,
    use_checkpoint=False,
    attention_resolutions="16",
    num_heads=1,
    num_head_channels=-1,
    num_heads_upsample=-1,
    use_scale_shift_norm=False,
    dropout=0,
    resblock_updown=False,
    use_fp16=False,
    use_new_attention_order=False,
    **kwargs
):
    if channel_mult == "":
        if image_size == 512:
            channel_mult = (0.5, 1, 1, 2, 2, 4, 4)
        elif image_size == 256:
            channel_mult = (1, 1, 2, 2, 4, 4)
        elif image_size == 128:
            channel_mult = (1, 1, 2, 3, 4)
        elif image_size == 64:
            channel_mult = (1, 2, 3, 4)
        else:
            raise ValueError(f"unsupported image size: {image_size}")
    else:
        channel_mult = tuple(int(ch_mult) for ch_mult in channel_mult.split(","))

    attention_ds = []
    for res in attention_resolutions.split(","):
        attention_ds.append(image_size // int(res))

    return UNetModel(
        image_size=image_size,
        in_channels=3,
        model_channels=num_channels,
        out_channels=(3 if not learn_sigma else 6),
        num_res_blocks=num_res_blocks,
        attention_resolutions=tuple(attention_ds),
        dropout=dropout,
        channel_mult=channel_mult,
        num_classes=(NUM_CLASSES if class_cond else None),
        use_checkpoint=use_checkpoint,
        use_fp16=use_fp16,
        num_heads=num_heads,
        num_head_channels=num_head_channels,
        num_heads_upsample=num_heads_upsample,
        use_scale_shift_norm=use_scale_shift_norm,
        resblock_updown=resblock_updown,
        use_new_attention_order=use_new_attention_order,
    )


def create_classifier(
    image_size,
    classifier_use_fp16,
    classifier_width,
    classifier_depth,
    classifier_attention_resolutions,
    classifier_use_scale_shift_norm,
    classifier_resblock_updown,
    classifier_pool,
    classifier_scale,
):
    if image_size == 512:
        channel_mult = (0.5, 1, 1, 2, 2, 4, 4)
    elif image_size == 256:
        channel_mult = (1, 1, 2, 2, 4, 4)
    elif image_size == 128:
        channel_mult = (1, 1, 2, 3, 4)
    elif image_size == 64:
        channel_mult = (1, 2, 3, 4)
    else:
        raise ValueError(f"unsupported image size: {image_size}")

    attention_ds = []
    for res in classifier_attention_resolutions.split(","):
        attention_ds.append(image_size // int(res))

    return EncoderUNetModel(
        image_size=image_size,
        in_channels=3,
        model_channels=classifier_width,
        out_channels=1000,
        num_res_blocks=classifier_depth,
        attention_resolutions=tuple(attention_ds),
        channel_mult=channel_mult,
        use_fp16=classifier_use_fp16,
        num_head_channels=64,
        use_scale_shift_norm=classifier_use_scale_shift_norm,
        resblock_updown=classifier_resblock_updown,
        pool=classifier_pool,
    )



def get_dataset(args, config):
    if config.data.random_flip is False:
        tran_transform = test_transform = transforms.Compose(
            [transforms.Resize(config.data.image_size), transforms.ToTensor()]
        )
    else:
        tran_transform = transforms.Compose(
            [
                transforms.Resize(config.data.image_size),
                transforms.RandomHorizontalFlip(p=0.5),
                transforms.ToTensor(),
            ]
        )
        test_transform = transforms.Compose(
            [transforms.Resize(config.data.image_size), transforms.ToTensor()]
        )

    if config.data.dataset == 'ImageNet':
        # only use validation dataset here
        
        if config.data.subset_1k:
            from .imagenet_subset import ImageDataset
            dataset = ImageDataset(os.path.join(args.exp, 'datasets', 'imagenet', 'imagenet'),
                     os.path.join(args.exp, 'imagenet_val_1k.txt'),
                     image_size=config.data.image_size,
                     normalize=False)
            test_dataset = dataset
        elif config.data.out_of_dist:
            dataset = torchvision.datasets.ImageFolder(
                os.path.join(args.exp, 'datasets', 'ood'),
                transform=transforms.Compose([partial(center_crop_arr, image_size=config.data.image_size),
                transforms.ToTensor()])
            )
            test_dataset = dataset
        else:
            dataset = torchvision.datasets.ImageNet(
                os.path.join(args.exp, 'datasets', 'imagenet'), split='val',
                transform=transforms.Compose([partial(center_crop_arr, image_size=config.data.image_size),
                transforms.ToTensor()])
            )
            test_dataset = dataset
    else:
        dataset, test_dataset = None, None

    return dataset, test_dataset


def center_crop_arr(pil_image, image_size = 256):
    # Imported from openai/guided-diffusion
    while min(*pil_image.size) >= 2 * image_size:
        pil_image = pil_image.resize(
            tuple(x // 2 for x in pil_image.size), resample=Image.BOX
        )

    scale = image_size / min(*pil_image.size)
    pil_image = pil_image.resize(
        tuple(round(x * scale) for x in pil_image.size), resample=Image.BICUBIC
    )

    arr = np.array(pil_image)
    crop_y = (arr.shape[0] - image_size) // 2
    crop_x = (arr.shape[1] - image_size) // 2
    return arr[crop_y : crop_y + image_size, crop_x : crop_x + image_size]


def logit_transform(image, lam=1e-6):
    image = lam + (1 - 2 * lam) * image
    return torch.log(image) - torch.log1p(-image)


def data_transform(config, X):
    if config.data.uniform_dequantization:
        X = X / 256.0 * 255.0 + torch.rand_like(X) / 256.0
    if config.data.gaussian_dequantization:
        X = X + torch.randn_like(X) * 0.01

    if config.data.rescaled:
        X = 2 * X - 1.0
    elif config.data.logit_transform:
        X = logit_transform(X)

    if hasattr(config, "image_mean"):
        return X - config.image_mean.to(X.device)[None, ...]

    return X


def seed_worker(seed):
    worker_seed = seed % 2 ** 32
    np.random.seed(worker_seed)
    random.seed(worker_seed)
    torch.manual_seed(worker_seed)


def inverse_data_transform(config, X):
    if hasattr(config, "image_mean"):
        X = X + config.image_mean.to(X.device)[None, ...]

    if config.data.logit_transform:
        X = torch.sigmoid(X)
    elif config.data.rescaled:
        X = (X + 1.0) / 2.0

    return torch.clamp(X, 0.0, 1.0)