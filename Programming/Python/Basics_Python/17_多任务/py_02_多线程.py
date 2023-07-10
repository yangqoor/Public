import threading
import time


def test1():
    for i in range(5):
        print("--------test1------%d----" % i)
        time.sleep(1)


def test2():
    for i in range(5):
        print("--------test2------%d----" % i)
        time.sleep(1)


def main():
    # 创建 Thread 对象
    t1 = threading.Thread(target=test1)
    t2 = threading.Thread(target=test2)

    # 启动程序，创建子线程，并开始执行
    # 如果 Thread 创建的函数执行结束，那么子线程结束
    t1.start()

    # time.sleep(1)
    # print("________1________")

    t2.start()

    # time.sleep(1)
    # print("________2________")

    while True:
        print(threading.enumerate())
        if len(threading.enumerate()) <= 1:
            break
        time.sleep(1)


if __name__ == '__main__':
    main()
