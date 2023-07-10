"""小文件复制"""
# # 1. 打开
# file_read = open("README")                # 只读
# file_write = open("README_copy", "w")     # 只写
#
# # 2. 读、写
# text = file_read.read()
# file_write.write(text)
#
# # 3. 关闭
# file_write.close()
# file_read.close()

"""大文件复制"""
# 打开
file_read = open("README")                # 只读
file_write = open("README_copy", "w")     # 追加

# 读写
while True:
    # 只读取一行
    text = file_read.readline()

    # 判断是否读取到内容
    if not text:
        break

    file_write.write(text)

# 关闭
file_write.close()
file_read.close()
