import greenlet
import time


def test1():
    while True:
        print("-----1----")
        gr2.switch()
        time.sleep(0.5)


def test2():
    while True:
        print("-----2----")
        gr1.switch()
        time.sleep(0.5)


gr1 = greenlet.greenlet(test1)   # 全局变量
gr2 = greenlet.greenlet(test2)

# 切换到gr1中运行
gr1.switch()
