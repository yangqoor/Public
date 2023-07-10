def measure():
    """测量温度和湿度"""
    print("测量开始...")
    temp = 39
    wetness = 50
    print("测量结束...")
    # 元组可以包含多个数据，可以让函数一次返回多个值
    # 如果返回的数据类型是元组，小括号可以省略
    # return (temp, wetness)
    return temp, wetness


# 结果保存为元组
result = measure()
print(result)

# 需要单独拿出温度或湿度
print(result[0])
print(result[1])

# 函数返回类型是元组，希望单独处理元组中的元素
# 可以使用多个变量，一次接收函数的返回结果，个数应保持一致
gl_temp, gl_wetness = measure()

print(gl_temp)
print(gl_wetness)
