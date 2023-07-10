from collections import Iterable
from collections import Iterator
import time


class Classmate(object):
    def __init__(self):
        self.names = list()
        self.current_num = 0

    def add(self, name):
        self.names.append(name)

    def __iter__(self):
        """__iter__ 方法使一个对象成为 可迭代对象"""
        # 返回值必须要有一个包含 __iter__ 和 __next__ 方法的对象
        return self

    def __next__(self):
        if self.current_num < len(self.names):
            ret = self.names[self.current_num]
            self.current_num += 1
            return ret
        else:
            # 抛出异常，for 自动停止
            raise StopIteration


# 可迭代对象
classmate = Classmate()

classmate.add("l")
classmate.add("w")
classmate.add("z")

# print("判断 clsaamate 对象是否可以迭代：", isinstance(classmate, Iterable))

# classmate_iterator = iter(classmate)
# print("判断 classmate_iterator 是否是迭代器", isinstance(classmate_iterator, Iterator))

# 调用 classmate_iterator 的 next 方法，使迭代器步进
# print(next(classmate_iterator))

for name in classmate:
    print(name)
    time.sleep(1)
