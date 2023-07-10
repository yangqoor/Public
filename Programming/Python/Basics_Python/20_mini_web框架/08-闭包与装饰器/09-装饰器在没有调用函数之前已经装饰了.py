def set_func(func):
    print("---开始进行装饰")

    def call_func(a):
        print("---这是权限验证1----")
        print("---这是权限验证2----")
        func(a)

    return call_func


# 遇到装饰器就开始执行，并不是调用test1时才执行
@set_func  # 相当于 test1 = set_func(test1)
def test1(num):
    print("-----test1----%d" % num)


@set_func  # 相当于 test2 = set_func(test2)
def test2(num):
    print("-----test2----%d" % num)

# 装饰器在调用函数之前，已经被python解释器执行了，所以要牢记 当调用函数之前 其实已经装饰好了，尽管调用就可以了
# test1(100)
# test2(200)
