# import 导入的是 全局变量、函数、类，
# 注意：直接执行的无缩进代码 如print("") 不是向外界提供的工具


def say_hello():

    print("你好你好，我是 say hello")


def main():
    """测试函数块

    """
    print(__name__)

    # 文件被导入时，期望直接执行的代码不被执行
    print("小明是作者")
    say_hello()


# 如果直接执行文件，__name__ 永远都是字符串 __main__
if __name__ == "__main__":
    main()
