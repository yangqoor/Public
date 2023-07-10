# 打印5行 *
# *
# **
# ***
"""
# 定义计数器变量，从1开始更方便
row = 1
# 开始循环
while row <= 5:
    print("*" * row)

    row += 1
"""

row = 1
# 开始循环
while row <= 5:
    # 每一行的*与当前行数是一致的
    # 增加循环，负责当前行中每一列的 * 数量
    # 定义列计数器
    col = 1
    while col <= row:
        # print("%d" % col)
        print("*", end="")        # 取消print的自动换行
        col += 1
    # print("第 %d 行" % row)
    print("")                     # 添加单纯的换行
    row += 1
