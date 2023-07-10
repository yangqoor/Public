# 定义一个函数 sum_numbers
# 计算 1+2+...+num


def sum_numbers(num):

    # 1. 出口
    if num == 1:
        return 1

    # 2. 数字累加
    temp = sum_numbers(num - 1)

    # 两个数字相加
    return num + temp


result = sum_numbers(100)
print(result)
