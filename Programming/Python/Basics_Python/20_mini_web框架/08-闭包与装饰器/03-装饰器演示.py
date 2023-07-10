def set_func(func):
    def call_func():
        print("---这是权限验证1----")
        print("---这是权限验证2----")
        func()

    return call_func   # 不能加括号，返回的是函数整体是一个对象，带括号是调用执行


@set_func
def test1():
    print("-----test1----")


test1()
