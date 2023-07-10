def demo1():
    # 定义一个局部变量
    # 1> 出生： num 执行赋值代码之后被创建
    num = 10

    print("在demo1函数内部的变量是 %d" % num)


def demo2():
    print("")


demo1()
# 2> 死亡：函数执行完后 num 变量死亡
