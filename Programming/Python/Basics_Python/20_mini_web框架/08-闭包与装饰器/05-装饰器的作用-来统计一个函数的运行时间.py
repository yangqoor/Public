import time


def set_func(func):
    def call_func():
        start_time = time.time()
        func()
        stop_time = time.time()
        print("alltimeis %f" % (stop_time - start_time))

    return call_func


@set_func  # 等价于test1 = set_func(test1)
def test1():
    print("-----test1----")
    for i in range(20000):
        a = 1 + 1


# ret = set_func(test1)
# ret()

# test1 = set_func(test1) 
test1()

test1()
