def set_func(func):
    print("---开始进行装饰")

    def call_func(*args, **kwargs):
        print("---这是权限验证1----")
        print("---这是权限验证2----")
        # func(args, kwargs)  # 不行，相当于传递了2个参数 ：1个元组，1个字典
        return func(*args, **kwargs)  # 拆包
        # 通用装饰器直接加上 return 即可，被装饰的函数有return才有返回值
    return call_func


@set_func  # 相当于 test1 = set_func(test1)
def test1(num, *args, **kwargs):
    print("-----test1----%d" % num)
    print("-----test1----", args)
    print("-----test1----", kwargs)
    # return "ok"


@set_func
def test2():
    pass


# 需要返回值，则闭包的内部函数
# 和 装饰器装饰的函数 需要有 return，否者返回 none
# 装饰器装饰的函数 将返回值给func，func前的return将返回值给 ret
ret = test1(100)
print(ret)

ret = test2()
print(ret)
