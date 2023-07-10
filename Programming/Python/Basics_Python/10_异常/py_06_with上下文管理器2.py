from contextlib import contextmanager


@contextmanager
def my_open(path, mode):
    my_f = open(path, mode)
    # with + 函数 执行后 yield 处先暂停
    yield my_f    # my_f 作为 as 后的值
    my_f.close()  # 无论有无异常都会执行


#
with my_open("1.txt", "w") as f:
    f.write("hello")
