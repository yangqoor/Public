import time


def test_1():
    while True:
        print("----1----")
        time.sleep(0.1)
        yield


def test_2():
    while True:
        print("----2----")
        time.sleep(0.1)
        yield


def main():
    t1 = test_1()
    t2 = test_2()
    # 并发，假的多任务
    while True:
        next(t1)
        next(t2)


if __name__ == "__main__":
    main()
