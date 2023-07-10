def test(num):

    print("在函数内部 %d 对应的内存地址是 %d" % (num, id(num)))
    # pass


# 1. 定义一个数字变量
a = 10

# 数据的地址本质上就是一个数字
print("a 变量保存数据的内存地址为 %d" % id(a))

# 2. 调用test函数,传递的是 引用
test(a)
