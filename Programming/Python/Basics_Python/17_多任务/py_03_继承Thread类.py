import threading
import time


class MyThread(threading.Thread):
    # 必须要有 run 函数
    def run(self) -> None:
        for i in range(3):
            time.sleep(1)
            msg = "I'm " + self.name + " @ " +str(i)
            print(msg)

    def login(self):
        print("Login message")

    def register(self):
        print("Please Register")


if __name__ == '__main__':
    t = MyThread()
    t.start()
    # 如果想多线程运行login register 函数，不能在此调用
    # 应在类中定义的 run 函数中调用
