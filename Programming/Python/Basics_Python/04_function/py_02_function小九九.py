def multiple_table():
    # 打印正三角的九九乘法表
    # ×前为列号，×后为行号
    # 打印9行*，将*替换为 列号×行号
    row = 1
    # 开始循环
    while row <= 9:
        # 每一行的*与当前行数是一致的
        # 增加循环，负责当前行中每一列的 * 数量
        # 定义列计数器
        col = 1
        while col <= row:
            # print("%d" % col)
            # print("*", end="")        # 取消print的自动换行
            # /t 制表位保持对齐
            print("%d×%d=%d" % (col, row, col * row), end="\t")
            col += 1
        # print("第 %d 行" % row)
        print("")  # 添加单纯的换行
        row += 1
