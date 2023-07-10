import random

# 先搜索当前文件夹，然后再系统目录
# 模块不要和系统模块文件同名
print(random.__file__)

rand = random.randint(0, 10)

print(rand)
