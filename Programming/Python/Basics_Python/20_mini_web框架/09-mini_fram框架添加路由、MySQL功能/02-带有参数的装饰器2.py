def set_level(level_num):
    def set_func(func):
        def call_func(*args, **kwargs):
            if level_num == 1:
                print("----权限级别1，验证----")
            elif level_num == 2:
                print("----权限级别2，验证----")
            return func()

        return call_func

    return set_func


# 带有参数的装饰器装饰过程分为2步:
# 1. 调用set_level函数，把1当做实参
# 2. set_level返回一个装饰器的引用，即set_func
# 3. 用返回的set_func对test1函数进行装饰（装饰过程与之前一样）
@set_level(1)
def test1():
    print("-----test1---")
    return "ok"
# 被装饰函数指向第三层的函数
# 第三层的函数 调用 第二层的形参函数，去使用第一层函数传递的参数值


@set_level(2)
def test2():
    print("-----test2---")
    return "ok"


test1()
test2()
