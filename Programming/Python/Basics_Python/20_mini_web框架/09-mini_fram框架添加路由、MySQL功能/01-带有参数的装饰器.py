def set_func(func):
    def call_func(*args, **kwargs):
        level = args[0]
        if level == 1:
            print("----权限级别1，验证----")
        elif level == 2:
            print("----权限级别2，验证----")
        return func(*args, **kwargs)

    return call_func


@set_func
def test1():
    print("-----test1---")
    return "ok"


@set_func
def test2():
    print("-----test2---")
    return "ok"


# 这种方式不好：（思路有问题）
# 1. 如果test1之前被调用了N次，那么就需要修改N个
# 2. 调用函数时，验证的级别应该是函数的开发者设定
#    而不是调用者设定
test1(1)
test2(2)
