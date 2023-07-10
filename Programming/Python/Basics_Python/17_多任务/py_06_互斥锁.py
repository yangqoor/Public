import threading
import time

g_num = 1


def test1(num):
    global g_num
    # 上锁，如果之前没有上锁，那么立即上锁
    # 如果之前已上锁，则堵塞在这里，直到这个锁被解开
    mutex.acquire()
    for i in range(num):
        g_num += 1
    # 解锁
    mutex.release()
    print("-----in------test1 g_num = %d" % g_num)


def test2(num):
    global g_num
    mutex.acquire()
    for i in range(num):
        g_num += 1
    mutex.release()
    print("-----in------test2 g_num = %d" % g_num)


# 创建互斥锁，默认没上锁
mutex = threading.Lock()


def main():
    t1 = threading.Thread(target=test1, args=(1000000,))
    t2 = threading.Thread(target=test2, args=(1000000,))

    t1.start()

    t2.start()

    # 等待两个子线程执行完毕
    time.sleep(2)
    print("-----in main Thread g_num = %d" % g_num)


if __name__ == '__main__':
    main()
