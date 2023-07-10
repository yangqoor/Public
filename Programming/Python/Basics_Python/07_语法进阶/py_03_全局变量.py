# 全局变量
num = 10


def demo1():
    # 希望修改全局变量的值
    # python中不允许直接修改全局变量的值
    # 如果使用赋值语句，会在函数内部定义一个局部变量
    # 使用 global 声明全局变量，即可在函数中修改全局变量
    global num
    num = 999
    print("demo1==> %d" % num)


def demo2():
    print("demo2==> %d" % num)


demo1()
demo2()
