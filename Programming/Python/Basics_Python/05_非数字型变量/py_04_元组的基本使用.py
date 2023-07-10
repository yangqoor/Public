info_tuple = ("zhangsan", 18, 1.75)

# 取值
print(info_tuple[0])
# 取索引
print(info_tuple.index(18))

# 统计计数
print(info_tuple.count("zhangsan"))
# 统计长度
print(len(info_tuple))

# 使用循环遍历元组
for my_info in info_tuple:
    # 由于元素数据类型不同，使用格式字符串拼接不方便
    print(my_info)
