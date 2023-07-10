def test1():
    print("*" * 30)


def test2():
    print("-" * 30)
    # 函数的嵌套调用
    test1()

    print("-" * 30)


test2()
