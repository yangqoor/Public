# 计算 0-100 的累加结果
# 定义最终结果变量
result = 0
# 定义整数变量，记录循环次数
i = 0

# 循环开始
while i <= 100:
    # print(i)
    # 每次循环 result 都与 i 相加
    result += i
    # 处理计数器
    i += 1
print("0-100 之间的数字求和 = %d" % result)
