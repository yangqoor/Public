import time
import threading


def sing():
    """唱歌5s"""
    for i in range(5):
        print("-----------正在唱歌-----------")
        time.sleep(1)


def dance():
    """跳舞5s"""
    for i in range(5):
        print("跳舞中..........")
        time.sleep(1)


def main():
    # 创建Thread类的实例对象
    t1 = threading.Thread(target=sing)
    t2 = threading.Thread(target=dance)

    # 启动程序，让子线程开始执行
    t1.start()
    t2.start()

    # while True:
    # length = len(threading.enumerate())
    # print(threading.enumerate())


if __name__ == '__main__':
    main()
