import multiprocessing


def download_for_web(q):
    # 模拟从网上下载的数据
    data = [1, 2, 3, 4]

    # 向队列中写入数据
    for temp in data:
        q.put(temp)

    print("....数据已经下载完毕，存入队列中...")


def analysis_data(q):
    """"数据处理"""
    # 从队列中获取数据
    waitting_analysis_data = list()       # 创建空列表

    while True:
        data = q.get()
        waitting_analysis_data.append(data)
        # 多进程导致 q 的数据获取结果不定
        if q.empty():
            break

    # 模拟数据处理
    print(waitting_analysis_data)


def main():
    # 1. 创建一个队列
    q = multiprocessing.Queue()      # 参数为空默认为空，由硬件决定大小

    p1 = multiprocessing.Process(target=download_for_web, args=(q, ))
    p2 = multiprocessing.Process(target=analysis_data, args=(q, ))

    p1.start()
    p2.start()


if __name__ == '__main__':
    main()
