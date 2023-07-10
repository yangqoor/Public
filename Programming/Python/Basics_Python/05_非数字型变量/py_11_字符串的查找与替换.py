hello_str = "hello world"

# 1. 判断是否以指定字符串开始
print(hello_str.startswith("hello"))

# 2. 判断是否以指定字符串结束
print(hello_str.endswith("world"))

# 3. 查找指定字符串
# 存在子字符串，返回索引；不存在，返回 -1
# 存在多个，返回第一个的索引
print(hello_str.find("llo"))

# 4. 替换字符串
# replace 返回一个新的字符串，不修改原字符串的内容
print(hello_str.replace("world", "python"))
print(hello_str)
