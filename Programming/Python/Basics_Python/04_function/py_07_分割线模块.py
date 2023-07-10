def print_line(char, times):
    """单行分割线"""
    print(char * times)
    # print(char * 50)
    # print("*" * 50)


def print_lines(char, times, rows):
    """打印多行分割线

    :param char: 分割线使用的字符
    :param times: 分割线长度
    :param rows: 分割线行数
    """
    row = 0

    while row < rows:
        print_line(char, times)
        row += 1


name = 'ly'
