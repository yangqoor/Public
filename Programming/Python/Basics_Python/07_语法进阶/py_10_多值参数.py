# * 元组 习惯用 *args
# ** 字典 用 **kwargs


def demo(num, *nums, **person):

    print(num)
    print(nums)
    print(person)


# demo(1)
# demo(1, 2, 3, 4, 5)
# demo(1, 2, 3, 4, 5, name="xiaoming", age=18)

# def sum_numbers(args):


def sum_numbers(*args):
    """任意个数数字求和

    :param args: 数字们
    :return: 结果
    """
    num = 0
    print(args)
    # 循环遍历
    for n in args:
        num += n

    return num


result = sum_numbers(1, 2, 3, 4, 5)
print(result)
