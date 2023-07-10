def add_qx(func):
    print("---开始进行装饰权限1的功能---")

    def call_func(*args, **kwargs):
        print("---这是权限验证1----")
        return func(*args, **kwargs)

    return call_func


def add_xx(func):
    print("---开始进行装饰xxx的功能---")

    def call_func(*args, **kwargs):
        print("---这是xxx的功能----")
        return func(*args, **kwargs)

    return call_func


# 装饰器谁在上边谁后装饰，但是先执行
@add_qx  # 2. 相当于 new_test1 = add_qx(new_test1) 此时new_test1指向add_qx.call_func(add_xx.call_func(test1))
@add_xx  # 1. 等价于 test1 = add_xx(test1) 此时test1指向add_xx.call_func(test1)
def test1():
    print("------test1------")


test1()
