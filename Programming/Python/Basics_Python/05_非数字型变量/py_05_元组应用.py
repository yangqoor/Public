info_tuple = ("小明", 18, 1.75)

# 格式化字符串后的（变量1, 变量3, 变量3,....）
# 本质上就是一个元组
print("%s年龄%d身高%.2f" % info_tuple)

# 格式化字符串拼接成一个新的字符串
info_str = "%s年龄%d身高%.2f" % info_tuple

print(info_str)
