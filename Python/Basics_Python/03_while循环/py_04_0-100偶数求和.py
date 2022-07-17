# 0-100 偶数求和
result = 0           # 结果变量
i = 0                # 计数器

while i <= 100:

    # 判断是否是偶数
    # 偶数i % 2 == 0
    # 奇数i % 2 ！= 0
    if i % 2 == 0:
        # print(i)
        result += i
    i += 1

print("0-100之间的偶数之和 = %d" % result)
