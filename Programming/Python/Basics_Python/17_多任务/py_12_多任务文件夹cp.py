import os
import multiprocessing


def copy_file(file_name, old_folder_name, new_folder_name):
    """完成文件复制"""
    print("=====>模拟copy文件：%s" % file_name)
    old_f = open(old_folder_name + "/" + file_name, "rb")
    content = old_f.read()
    old_f.close()

    new_f = open(new_folder_name + "/" + file_name, "wb")
    new_f.write(content)
    new_f.close()


def main():
    # 1. 获取文件夹名
    old_folder_name = input("请输入要copy的文件夹名：")

    # 2. 创建新文件夹
    try:
        # 如果存在则跳过
        new_folder_name = old_folder_name + "[copy]"
        os.mkdir(new_folder_name)
    except:
        pass

    # 3. 获取所有的文件名 os.listdir()
    files_name = os.listdir(old_folder_name)
    # print(files_name)

    # 4. 创建进程池
    # 进程池中产生异常不会有报错信息
    po = multiprocessing.Pool(5)

    # 5. 向进程池中添加 copy 文件的任务
    for name in files_name:
        po.apply_async(copy_file, args=(name, old_folder_name, new_folder_name))

    po.close()
    po.join()
    # 复制源文件夹中的文件到新文件夹中


if __name__ == '__main__':
    main()
