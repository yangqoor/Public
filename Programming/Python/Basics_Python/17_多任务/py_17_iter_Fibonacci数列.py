from collections import Iterator


# 没有占用大量空间的列表
class Fibonacci(object):
    def __init__(self, all_num):
        self.current_num = 0
        self.all_num = all_num
        self.a = 0
        self.b = 1

    def __iter__(self):
        """__iter__ 方法使一个对象成为 可迭代对象"""
        # 返回值必须要有一个包含 __iter__ 和 __next__ 方法的对象
        return self

    def __next__(self):
        if self.current_num < self.all_num:
            ret = self.a

            self.a, self.b = self.b, self.a + self.b

            self.current_num += 1
            return ret
        else:
            # 抛出异常，for 自动停止
            raise StopIteration


# 可迭代对象
fibo = Fibonacci(10)
# 判断是否是可迭代对象
print(isinstance(iter(fibo), Iterator))

for num in fibo:
    print(num)
