import multiprocessing
import time
import os
import random


def worker(msg):
    t_start = time.time()
    print("%s开始执行，进程号为%d" % (msg, os.getpid()))
    # random.random()随机生成0-1之间的浮点数
    time.sleep(random.random()*2)
    t_stop = time.time()
    print(msg, "执行完毕，耗时%.2f" % (t_stop - t_start))


def main():
    # 定义一个进程池，最大进程数为3（只定义，不创建）
    po = multiprocessing.Pool(3)

    for i in range(0, 10):
        # po.apply_async(要调用的函数名, (目标参数的元组, ))
        # 每次循环用空闲出来的子进程调用目标
        po.apply_async(worker, (i, ))

    print("--------start--------")
    # 关闭进程池，不再接受新请求
    po.close()
    """等待po中所有子进程执行结束，必须在close之后
    若没有 join ，主进程不会等待"""
    po.join()
    print("--------end--------")


if __name__ == '__main__':
    main()
