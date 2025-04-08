from diffusers import StableDiffusionControlNetPipeline, ControlNetModel, UniPCMultistepScheduler
from diffusers.utils import load_image
import torch
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from torchvision import transforms



# 设置模型路径
checkpoint_step = 300 # 要加载哪个step的模型
base_sd_model_path = "D:/stable-diffusion-v1-5" # 基本的sdv 1-5的权重的路径
base_controlnet_output_dir = "results/controlnet_diffusers" # controlnet的路径
grid_output_path = f"results/controlnet_diffusers/test_images/grid_output_{checkpoint_step}.png"

controlnet_path = f"{base_controlnet_output_dir}/checkpoint-{checkpoint_step}/controlnet"

# 加载模型
controlnet = ControlNetModel.from_pretrained(controlnet_path)
pipe = StableDiffusionControlNetPipeline.from_pretrained(base_sd_model_path, controlnet=controlnet)

# 优化扩散过程
pipe.scheduler = UniPCMultistepScheduler.from_config(pipe.scheduler.config)

# 设置安全检查器
pipe.safety_checker = lambda images, clip_input: (images, None)

# 示例：多张图片的路径
images_path = [
    "datasets/underwater_distorted/conditioning_images/hand_0001.jpg",
    "datasets/underwater_distorted/conditioning_images/hand_0002.jpg",
    "datasets/underwater_distorted/conditioning_images/hand_0003.jpg"
]

# 示例：对应每张图片的提示语
prompts = [
    "restore",
    "restore",
    "restore"
]

# 创建一个n x 3的网格，n是图像的数量
n = len(images_path)

# 创建一个n行3列的子图网格
fig, axes = plt.subplots(n, 3, figsize=(15, 5 * n))

# 确保axes是一个二维数组，即使n=1
if n == 1:
    axes = [axes]

image_transforms = transforms.Compose([
    transforms.Resize(512, interpolation=transforms.InterpolationMode.BILINEAR),
    transforms.CenterCrop(512),
    transforms.ToTensor(),
    transforms.Normalize([0.5], [0.5]),
])

# 遍历每张源图片，生成对应的图像并显示
for i, (image_path, prompt) in enumerate(zip(images_path, prompts)):
    # 加载控制图像
    control_image = load_image(image_path)

    # # 将模型移动到指定的GPU
    pipe.to("cuda:0")

    # 设置生成器的随机种子
    generator = torch.manual_seed(0)

    # 生成图像
    generated_image = pipe(
        prompt, num_inference_steps=40, generator=generator, image=control_image
    ).images[0]

    # 在第i行填充网格中的三个格子
    # 第一个格子：控制图像
    axes[i][0].imshow(control_image)
    axes[i][0].axis('off')
    axes[i][0].set_title("Control Image")

    # 第二个格子：生成的图像
    axes[i][1].imshow(generated_image)
    axes[i][1].axis('off')
    axes[i][1].set_title("Generated Image")

    # 第三个格子：显示prompt文本
    axes[i][2].text(0.5, 0.5, prompt, fontsize=12, ha='center', va='center', wrap=True)
    axes[i][2].axis('off')
    axes[i][2].set_title("Prompt")

# 调整布局，确保内容不重叠
plt.tight_layout()

# 保存网格为本地文件
plt.savefig(grid_output_path, bbox_inches='tight')
print(f"输出路径是:{grid_output_path}")
