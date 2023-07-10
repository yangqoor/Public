import gevent
import time
from gevent import monkey

# 有耗时操作时
monkey.patch_all()  # 将程序中有耗时的代码，换为gevent中自己实现的模块


def f1(n):
    for i in range(n):
        print(gevent.getcurrent(), i)
        time.sleep(0.5)
        # 一般要用 gevent 自己的延时方法
        # gevent.sleep(0.5)


def f2(n):
    for i in range(n):
        print(gevent.getcurrent(), i)
        gevent.sleep(0.5)


def f3(n):
    for i in range(n):
        print(gevent.getcurrent(), i)
        gevent.sleep(0.5)

"""
print("------1------")
g1 = gevent.spawn(f1, 5)
print("------2------")
g2 = gevent.spawn(f2, 5)
print("------3------")
g3 = gevent.spawn(f3, 5)    # 只是创建对象，不执行函数
print("------4------")

g1.join()
g2.join()
g3.join()
"""

gevent.joinall([gevent.spawn(f1, 5),
                gevent.spawn(f2, 5),
                gevent.spawn(f3, 5)])
