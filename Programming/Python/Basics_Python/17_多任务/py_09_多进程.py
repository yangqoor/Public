import multiprocessing
import time


def test1():
    while True:
        print("------1------")
        time.sleep(1)


def test2():
    while True:
        print("------2------")
        time.sleep(1)


def main():

    p1 = multiprocessing.Process(target=test1)
    p2 = multiprocessing.Process(target=test2)

    p1.start()
    p2.start()


if __name__ == '__main__':
    main()
