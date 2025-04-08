import os
import json

# 配置路径
images_dir = '/controlnet/datasets/underwater_distorted/images'
conditioning_dir = '/controlnet/datasets/underwater_distorted/conditioning_images'
output_filename = '/controlnet/datasets/underwater_distorted/train.jsonl'

# 获取images目录下所有文件（排除目录）
image_files = [f for f in os.listdir(images_dir) 
              if os.path.isfile(os.path.join(images_dir, f))]

# 生成并写入JSONL文件
with open(output_filename, 'w', encoding='utf-8') as f:
    for filename in image_files:
        # 构建每个JSON对象
        entry = {
            "text": "restore",
            "image": f"images/{filename}",
            "conditioning_image": f"conditioning_images/{filename}"
        }
        # 写入JSON行
        f.write(json.dumps(entry, ensure_ascii=False) + '\n')

print(f"已生成 {len(image_files)} 条记录到 {output_filename}")