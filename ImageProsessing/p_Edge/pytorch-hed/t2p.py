import paddle
import torch
import numpy as np

def convert_pytorch_to_paddle(pytorch_model_path, paddle_model_path):
    """
    将PyTorch模型权重转换为PaddlePaddle格式
    """
    # 加载PyTorch权重
    torch_state_dict = torch.load(pytorch_model_path, map_location='cpu')
    
    paddle_state_dict = {}
    
    for torch_key, torch_value in torch_state_dict.items():
        # 转换键名
        paddle_key = torch_key.replace('module', 'net')
        
        # 转换权重值
        if torch_value.dim() == 4:  # 卷积权重
            paddle_value = torch_value.detach().numpy()
        elif torch_value.dim() == 1:  # 偏置项
            paddle_value = torch_value.detach().numpy()
        else:  # 其他参数
            paddle_value = torch_value.detach().numpy()
        
        paddle_state_dict[paddle_key] = paddle_value
    
    # 保存PaddlePaddle权重
    paddle.save(paddle_state_dict, paddle_model_path)
    print(f"模型转换完成！Paddle权重保存至: {paddle_model_path}")

# 使用示例
if __name__ == "__main__":
    convert_pytorch_to_paddle('network-bsds500.pytorch', 'network-bsds500.pdparams')