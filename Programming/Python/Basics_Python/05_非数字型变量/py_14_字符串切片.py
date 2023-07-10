num_str = "0123456789"

# 提取 2-5
print(num_str[2:6])
# 截取 2-9
print(num_str[2:])
# 截取 开始-5
print(num_str[:6])
# 截取完整字符,开始和结束的索引都可省略
print(num_str[:])
# 从开始 每隔一个取一个
print(num_str[::2])
# 从1开始 每隔一个取一个
print(num_str[1::2])
# 截取 2-（末尾-1）
print(num_str[2:-1])
# 截取末尾两个字符
print(num_str[-2:])
# 字符串逆序（面试版）
# 从最后一个字符开始，向左移动
print(num_str[-1::-1])
print(num_str[::-1])
