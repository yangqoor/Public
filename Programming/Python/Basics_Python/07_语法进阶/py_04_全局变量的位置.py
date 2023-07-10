# 全局变量应定义在所有函数上方
gl_num = 10
gl_name = "小明"
title = "程序员"


def demo():
    # 全局变量与局部变量名字相同，变量下会有灰色下划线
    num = 123
    print("%d" % num)
    print("%s" % title)
    print("%s" % gl_name)


# 定义一个全局变量
# title = "程序员"

demo()

# 定义第二个全局变量
# name = "小明"
